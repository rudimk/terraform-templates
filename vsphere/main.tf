variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_template" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vsphere_host" {
  type = string
}

variable "vm_guest" {
  type = string
}

variable "vm_domain" {
  type = string
}

variable "vm_ip" {
  type = string
}

variable "vm_vcpu" {
  type = number
}

variable "vm_ram" {
  type = number
}

variable "vm_disk" {
  type = number
}

variable "ssh_user" {
  type = string
}

variable "ssh_passwd" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}


provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = var.vm_vcpu
  memory   = var.vm_ram
  guest_id = var.vm_guest
  host_system_id = var.vsphere_host
  #vvtd_enabled = false

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = var.vm_disk
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }


  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = 24
      }
      dns_server_list = ["8.8.8.8"]

      ipv4_gateway = "172.31.31.254"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/.ssh",
      "touch /home/${var.ssh_user}/.ssh/authorized_keys",
      "echo ${var.ssh_pub_key} >> /home/${var.ssh_user}/.ssh/authorized_keys",
      "sudo growpart /dev/sda 2",
      "sudo resize2fs /dev/sda2"
    ]
  }
  connection {
    host = var.vm_ip
    type = "ssh"
    user = var.ssh_user
    password = var.ssh_passwd
  }
}
