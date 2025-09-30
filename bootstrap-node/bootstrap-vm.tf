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
    "stealclock.enable"                        = "TRUE"
    "disk.EnableUUID"                          = "TRUE"
  }

  tags = var.vm_tags
}
