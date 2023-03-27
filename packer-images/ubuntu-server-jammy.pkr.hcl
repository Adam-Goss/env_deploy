# Ubuntu Server Jammy
# -------------------

# variable definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive =  true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive =  true
}


# resource definition
source "proxmox" "ubuntu-server-jammy" {
    # proxmox connection settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true 

    # vm general settings
    node = "pve"
    vm_id = "9000"
    vm_name = "ubuntu-server-jammy"
    template_description = "Ubuntu Server Jammy Test Image"

    # vm os settings
    iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true

    # vm system settings
    qemu_agent = true 

    # vm hard disk settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "disk_images"
        storage_pool_type = "lvm-thin"
        type = "sata"
    }

    # vm cpu settings
    cores = "1"

    # vm memory 
    memory = "2048"

    # vm network settings 
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # vm cloud-init settings
    cloud_init = true 
    cloud_init_storage_pool = "disk_images"

    # packer boot commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"


    # packer autoinstall settings
    http_directory = "http"
    http_bind_address = "0.0.0.0"
    http_port_min = 8802
    http_port_max = 8802

    ssh_username = "test"
    ssh_password = "test"

    ssh_timeout = "20m"
}

# build definition to create the vm template 
build {
    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }


    # install docker
    provisioner "shell" {
        inline = [ 
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "sudo mkdir -m 0755 -p /etc/apt/keyrings",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
            "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get update",
            "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        ]
    }
}
