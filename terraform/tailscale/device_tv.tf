data "tailscale_device" "tv" {
  name = "tv.bunny-morray.ts.net"
}

resource "tailscale_device_authorization" "tv" {
  device_id  = data.tailscale_device.tv.node_id
  authorized = true
}

resource "tailscale_device_key" "tv" {
  device_id           = data.tailscale_device.tv.node_id
  key_expiry_disabled = true
}
