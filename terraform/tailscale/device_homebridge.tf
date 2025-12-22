data "tailscale_device" "homebridge" {
  name = "homebridge.bunny-morray.ts.net"
}

resource "tailscale_device_authorization" "homebridge" {
  device_id  = data.tailscale_device.homebridge.node_id
  authorized = true
}

resource "tailscale_device_key" "homebridge" {
  device_id           = data.tailscale_device.homebridge.node_id
  key_expiry_disabled = true
}
