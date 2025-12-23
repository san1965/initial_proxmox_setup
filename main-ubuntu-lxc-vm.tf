resource "proxmox_virtual_environment_apt_standard_repository" "pve" {
  handle = "no-subscription"
  node   = "pve"
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i inventory.ini proxmox-init.yml"
  }
  depends_on = [proxmox_virtual_environment_download_file.ubuntu_2404_lxc_img]
}
resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Opentofu"
  tags        = ["template", "ubuntu","lxc"]
  node_name = "pve" 
  vm_id = 8000
  started = true
  cpu {
    cores        = 2
  }
  memory {
    dedicated = 1024
    swap      = 0
  } 
  start_on_boot = false
  unprivileged = true
  features {
    nesting = true
  }
  initialization {
    hostname = "ubuntu-lxc"
    dns {
      servers = ["8.8.8.8"]
    }
    ip_config {
      ipv4 {
        address = "192.168.1.37/24"
        gateway = "192.168.1.1"
      }
    }
    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }
  network_interface {
    name = "veth0"
  }
  disk {
    datastore_id = "local-lvm"
    size         = 15
  }
  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.ubuntu_2404_lxc_img.id
    type             = "ubuntu"
  }
  connection {
   type        = "ssh"
   user        = "root"
   private_key = trimspace(tls_private_key.ubuntu_key.private_key_pem)
   host        = split("/", self.initialization[0].ip_config[0].ipv4[0].address)[0]
   port        = 22
   timeout     = "5m"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -f /var/lib/apt/lists/lock /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock",
      "apt-get update",
      "apt-get -y upgrade"
    ]
  }
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i inventory.ini lxc-template.yml"
  }
  depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]
}
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "ubuntu-vm"
  description = "Managed by Tofu"
  tags        = ["template", "ubuntu","vm"]
  node_name = "pve"
  vm_id     = 9000
  started = false
  agent {
    enabled = true
  }
  cpu {
    cores        = 2
  }
  memory {
    dedicated = 2048
  }
  scsi_hardware = "virtio-scsi-single"
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu-24_04_noble_qcow2_img.id
    interface    = "scsi0"
    size         = 15
    discard      = "on" 
    iothread     = true
    ssd          = true
  }
  initialization {
    dns {
      servers = ["8.8.8.8"]
    }
    ip_config {
      ipv4 {
        address = "192.168.1.137/24"
        gateway = "192.168.1.1"
      }
    }
    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = "ubuntu"
    }
  }
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
  operating_system {
    type = "l26"
  }
  serial_device {}
  vga {
    type = "serial0"
  }
  connection {
   type        = "ssh"
   user        = "ubuntu"
   private_key = trimspace(tls_private_key.ubuntu_key.private_key_pem)
   host        = split("/", self.initialization[0].ip_config[0].ipv4[0].address)[0]
   port        = 22
   timeout     = "10m"
  }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 3; done",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt install -y qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent"
    ]
  }
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i inventory.ini vm-template.yml"
  }
  depends_on = [proxmox_virtual_environment_apt_standard_repository.pve]
}
resource "proxmox_virtual_environment_download_file" "ubuntu_2404_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve"
  url          = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  overwrite           = false
}
resource "proxmox_virtual_environment_download_file" "ubuntu-24_04_noble_qcow2_img" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url = "https://cloud-images.ubuntu.com/daily/server/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  file_name = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
  overwrite           = false
}
resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}
resource "tls_private_key" "ubuntu_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}
output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}
output "ubuntu_private_key" {
  value     = tls_private_key.ubuntu_key.private_key_pem
  sensitive = true
}
output "ubuntu_public_key" {
  value = tls_private_key.ubuntu_key.public_key_openssh
}
output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}
