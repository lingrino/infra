#!/usr/bin/env bash
set -euo pipefail

# Discovers Terraform workspaces and their module dependencies, then
# determines which workspaces are affected by changed files.
#
# Inputs (env vars):
#   BASE_REF       - Git ref to diff against (e.g. origin/main, HEAD~1)
#   ALL_WORKSPACES - If "true", return all workspaces (skip change detection)
#   FILTER         - Comma-separated workspace paths to filter to (optional)
#
# Outputs (via $GITHUB_OUTPUT):
#   matrix      - JSON array of objects: [{"path":"terraform/github"}, ...]
#   has_changes - "true" or "false"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

# Discover all workspaces: directories containing meta.tf with a backend "s3" block
declare -a ALL_WS=()
while IFS= read -r meta_file; do
  if grep -q 'backend "s3"' "${meta_file}"; then
    ALL_WS+=("$(dirname "${meta_file}")")
  fi
done < <(find terraform -name "meta.tf" -type f | sort)

echo "Discovered ${#ALL_WS[@]} workspaces:"
printf '  %s\n' "${ALL_WS[@]}"

# Discover all module names
declare -a ALL_MODS=()
for dir in terraform-modules/*/; do
  ALL_MODS+=("$(basename "${dir}")")
done

# Build module-to-module dependency map (module -> modules it depends on)
# Modules reference each other via relative paths like source = "../s3//"
declare -A MOD_TO_MOD=()
for mod in "${ALL_MODS[@]}"; do
  while IFS= read -r dep; do
    MOD_TO_MOD["${mod}"]+="${dep} "
  done < <(grep -rh 'source\s*=\s*"\.\./' "terraform-modules/${mod}"/*.tf 2>/dev/null | \
    sed -E 's|.*"\.\./([^/"]+)//.*|\1|' | sort -u)
done

# Build transitive closure: for each module, find all modules that transitively
# depend on it (i.e. if s3 changes, account-base is also affected because it
# uses s3, so any workspace using account-base is affected too)
# Returns space-separated list of modules that depend on the given module
get_reverse_deps() {
  local target="$1"
  local -A visited=()
  local -a queue=("${target}")
  while [[ ${#queue[@]} -gt 0 ]]; do
    local current="${queue[0]}"
    queue=("${queue[@]:1}")
    [[ -n "${visited[${current}]:-}" ]] && continue
    visited["${current}"]=1
    # Find all modules that directly depend on current
    for mod in "${ALL_MODS[@]}"; do
      if [[ " ${MOD_TO_MOD[${mod}]:-} " == *" ${current} "* ]]; then
        queue+=("${mod}")
      fi
    done
  done
  echo "${!visited[@]}"
}

# Build module dependency map: module_name -> list of workspaces that use it
# (including transitive dependents)
declare -A MODULE_DEPS=()
for ws in "${ALL_WS[@]}"; do
  while IFS= read -r mod; do
    MODULE_DEPS["${mod}"]+="${ws} "
  done < <(grep -rh 'source.*terraform-modules/' "${ws}"/*.tf 2>/dev/null | \
    sed -E 's/.*terraform-modules\/([^/"]+)\/\/.*/\1/' | sort -u)
done

# Expand MODULE_DEPS with transitive dependencies: if module A depends on
# module B, then workspaces using A should also be triggered by changes to B
declare -A EXPANDED_MODULE_DEPS=()
for mod in "${ALL_MODS[@]}"; do
  # Get all modules that are affected when this module changes (itself + reverse deps)
  affected_mods=$(get_reverse_deps "${mod}")
  # Collect all workspaces that use any of those affected modules
  ws_list=""
  for affected_mod in ${affected_mods}; do
    ws_list+="${MODULE_DEPS[${affected_mod}]:-}"
  done
  EXPANDED_MODULE_DEPS["${mod}"]="${ws_list}"
done

# Determine affected workspaces
declare -A AFFECTED=()

if [[ "${ALL_WORKSPACES:-false}" == "true" ]]; then
  for ws in "${ALL_WS[@]}"; do
    AFFECTED["${ws}"]=1
  done
else
  # Get changed files
  CHANGED_FILES=$(git diff --name-only "${BASE_REF:-origin/main}" 2>/dev/null || true)

  if [[ -z "${CHANGED_FILES}" ]]; then
    echo "No changed files detected."
  else
    echo ""
    echo "Changed files:"
    echo "${CHANGED_FILES}" | sed 's/^/  /'

    while IFS= read -r file; do
      # CI/workflow changes affect all workspaces
      if [[ "${file}" == .github/workflows/terraform-* ]] || [[ "${file}" == .github/scripts/* ]]; then
        for ws in "${ALL_WS[@]}"; do
          AFFECTED["${ws}"]=1
        done
        break
      fi

      # Direct workspace file change
      for ws in "${ALL_WS[@]}"; do
        if [[ "${file}" == "${ws}/"* ]]; then
          AFFECTED["${ws}"]=1
        fi
      done

      # Module change -> all dependent workspaces (including transitive)
      if [[ "${file}" == terraform-modules/* ]]; then
        mod_name=$(echo "${file}" | sed -E 's|terraform-modules/([^/]+)/.*|\1|')
        if [[ -n "${EXPANDED_MODULE_DEPS[${mod_name}]:-}" ]]; then
          for ws in ${EXPANDED_MODULE_DEPS[${mod_name}]}; do
            AFFECTED["${ws}"]=1
          done
        fi
      fi
    done <<< "${CHANGED_FILES}"
  fi
fi

# Apply filter if specified
declare -A FILTERED=()
if [[ -n "${FILTER:-}" ]]; then
  IFS=',' read -ra FILTER_PATHS <<< "${FILTER}"
  for fp in "${FILTER_PATHS[@]}"; do
    fp=$(echo "${fp}" | xargs) # trim whitespace
    if [[ -n "${AFFECTED[${fp}]:-}" ]]; then
      FILTERED["${fp}"]=1
    fi
  done
  # Replace AFFECTED with FILTERED
  unset AFFECTED
  declare -A AFFECTED
  for key in "${!FILTERED[@]}"; do
    AFFECTED["${key}"]=1
  done
fi

# Build output
AFFECTED_LIST=()
for ws in "${!AFFECTED[@]}"; do
  AFFECTED_LIST+=("${ws}")
done

# Sort for deterministic output
if [[ ${#AFFECTED_LIST[@]} -gt 0 ]]; then
  IFS=$'\n' AFFECTED_LIST=($(sort <<< "${AFFECTED_LIST[*]}")); unset IFS
fi

echo ""
echo "Affected workspaces (${#AFFECTED_LIST[@]}):"
if [[ ${#AFFECTED_LIST[@]} -gt 0 ]]; then
  printf '  %s\n' "${AFFECTED_LIST[@]}"
fi

# Build JSON matrix
if [[ ${#AFFECTED_LIST[@]} -eq 0 ]]; then
  MATRIX="[]"
  HAS_CHANGES="false"
else
  MATRIX=$(printf '%s\n' "${AFFECTED_LIST[@]}" | jq -R '{"path": .}' | jq -s -c '.')
  HAS_CHANGES="true"
fi

echo ""
echo "Matrix: ${MATRIX}"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "matrix=${MATRIX}" >> "${GITHUB_OUTPUT}"
  echo "has_changes=${HAS_CHANGES}" >> "${GITHUB_OUTPUT}"
fi
