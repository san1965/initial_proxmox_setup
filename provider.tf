terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.87.0" # x-release-please-version
    }
  }
}
provider "proxmox" {
  endpoint  = "https://192.168.1.100:8006"
  api_token = "tofu@pve!provider=ae468adc-f2ba-4072-b9c8-7e3e8a46beac"
  insecure  = true
  ssh {
    agent    = true
    username = "root"
    private_key = "~/virtualization/.ssh/id_ed25519"
  }
}