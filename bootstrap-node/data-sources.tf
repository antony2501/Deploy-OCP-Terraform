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
