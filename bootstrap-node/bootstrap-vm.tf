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
    "guestinfo.ignition.config.url"            = "http://${var.bastion_ip}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
    "guestinfo.ignition.config.url.sha256"     = var.bootstrap_ign_sha256 # optional nếu bạn có checksum
    "guestinfo.afterburn.initrd.network-kargs" = "ip=10.0.98.80::10.0.98.1:255.255.255.0:bootstrap.oc1.cloud.lab:ens192:none nameserver=10.1.102.42"
  }

  tags = var.vm_tags
}
