resource "tailscale_acl" "acl" {
  acl = jsonencode({
    grants = [
      {
        src = ["autogroup:owner"]
        dst = ["*"]
        ip  = ["*"]
      },
      {
        src = ["autogroup:member"]
        dst = ["autogroup:self"]
        ip  = ["*"]
      }
    ]
    nodeAttrs = [
      {
        attr   = ["funnel"]
        target = ["autogroup:owner"]
      }
    ]
    ssh = [
      {
        action = "accept"
        src    = ["autogroup:owner"]
        dst    = ["autogroup:self"]
        users  = ["root", "autogroup:nonroot"]
      }
    ]
  })
}
