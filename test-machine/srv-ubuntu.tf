resource "proxmox_vm_qemu" "cloudinit-test" {

    name = "srv-ubuntu"
    desc = "Ubuntu Server"

    target_node = "pve"


    vmid = "8001"

    agent = 1

    clone = "ubuntu-server-22.04"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 2048

    network  {
        bridge = "vmbr0"
        model = "virtio"
    }

    disk {
        storage = "disk_images"
        type = "virtio"
        size = 32
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.200,gw=192.168.1.1"
    nameserver = "8.8.8.8"
    ciuser = "test"
    cipassword = "test"

}