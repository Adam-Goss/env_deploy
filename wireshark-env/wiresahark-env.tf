resource "proxmox_vm_qemu" "Attacker" {

    target_node = "pve"
    vmid = "9001"
    name = "Attacker"
    desc = "Attacker - Kali Linux"




    #onboot = true

    full_clone = true

    agent = 1

    clone = "kali-2023-1-template"
    cores = 2
    sockets = 1
    cpu = "host"

    memory = 4096

    scsihw = "virtio-scsi-pci"

    network  {
        bridge = "vmbr0"
        model = "virtio"
    }

    disk {
        storage = "disk_images"
        discard = "on"
        iothread = 0
        size = "32G"
        slot = 0
        ssd = 0
        type = "scsi"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    # ipconfig0 = "ip=0.0.0.0/0,gw=0.0.0.0"
    
    # (Optional) Default User
    # ciuser = "your-username"
    
    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # #YOUR-PUBLIC-SSH-KEY
    # EO

}


resource "proxmox_vm_qemu" "Defender" {

    target_node = "pve"
    vmid = "9002"
    name = "Defender"
    desc = "Defender - Ubuntu Server"
    boot = "order=scsi0;net0"



    #onboot = true

    full_clone = true

    agent = 1

    clone = "ubuntu-2204-template"
    cores = 2
    sockets = 1
    cpu = "host"

    memory = 4096

    scsihw = "virtio-scsi-pci"

    network  {
        bridge = "vmbr0"
        model = "virtio"
    }

    disk {
        storage = "disk_images"
        discard = "on"
        iothread = 0
        size = "32G"
        slot = 0
        ssd = 0
        type = "scsi"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    # ipconfig0 = "ip=0.0.0.0/0,gw=0.0.0.0"
    
    # (Optional) Default User
    # ciuser = "your-username"
    
    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # #YOUR-PUBLIC-SSH-KEY
    # EO

}
