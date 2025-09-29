# ====== DATA LOOKUP CƠ BẢN ======
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter_name
}

data "vsphere_datastore" "ds" {
  name          = var.vsphere_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.vsphere_portgroup_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "rp" {
  name          = var.vsphere_resource_pool_path  # vd: "/Amigo/host/Amigo/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template VM (đã deploy sẵn từ OVA)
data "vsphere_virtual_machine" "template" {
  name          = var.template_vm_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ====== BOOTSTRAP VM ======
# Cách 1: Dùng URL (web server trên bastion phục vụ bootstrap.ign)
resource "vsphere_virtual_machine" "bootstrap" {
  name             = "${var.cluster_name}-bootstrap"
  folder           = var.vsphere_folder
  resource_pool_id = data.vsphere_resource_pool.rp.id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 4
  memory   = 16384
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Guestinfo: bootstrap nên dùng URL cho file bootstrap.ign
  extra_config = {
    "guestinfo.ignition.config.url"            = "http://${var.bastion_ip}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
    "guestinfo.ignition.config.url.sha256"     = var.bootstrap_ign_sha256 # optional nếu bạn có checksum
    "guestinfo.afterburn.initrd.network-kargs" = "ip=dhcp"
  }

  tags = var.vm_tags
}

# ====== CONTROL PLANE (MASTER) VMs ======
resource "vsphere_virtual_machine" "master" {
  count           = 3
  name            = "${var.cluster_name}-master-${count.index}"
  folder          = var.vsphere_folder
  resource_pool_id = data.vsphere_resource_pool.rp.id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 4
  memory   = 16384
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Guestinfo: truyền master.ign (base64)
  extra_config = {
    "guestinfo.ignition.config.data"          = var.master_ign_base64
    "guestinfo.ignition.config.data.encoding" = "base64"
    "guestinfo.afterburn.initrd.network-kargs" = "ip=dhcp"
  }

  tags = var.vm_tags
}

# ====== WORKER VMs ======
resource "vsphere_virtual_machine" "worker" {
  count            = var.worker_count
  name             = "${var.cluster_name}-worker-${count.index}"
  folder           = var.vsphere_folder
  resource_pool_id = data.vsphere_resource_pool.rp.id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 2
  memory   = 8192
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Guestinfo: truyền worker.ign (base64)
  extra_config = {
    "guestinfo.ignition.config.data"          = var.worker_ign_base64
    "guestinfo.ignition.config.data.encoding" = "base64"
    "guestinfo.afterburn.initrd.network-kargs" = "ip=dhcp"
  }

  tags = var.vm_tags
}