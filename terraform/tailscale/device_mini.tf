data "tailscale_device" "mini" {
  name = "mini.bunny-morray.ts.net"
}

resource "tailscale_device_authorization" "mini" {
  device_id  = data.tailscale_device.mini.node_id
  authorized = true
}

resource "tailscale_device_key" "mini" {
  device_id           = data.tailscale_device.mini.node_id
  key_expiry_disabled = true
}
