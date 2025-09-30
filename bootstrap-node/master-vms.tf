# ====== CONTROL PLANE (MASTER) VMs ======
resource "vsphere_virtual_machine" "master" {
  count           = 3
  name            = "${var.cluster_name}-master-${count.index}"
  folder          = var.vsphere_folder
  resource_pool_id = data.vsphere_resource_pool.rp.id
  datastore_id     = data.vsphere_datastore.ds.id
  
  # Đảm bảo bootstrap VM được tạo và khởi động hoàn toàn trước
  depends_on = [time_sleep.wait_for_bootstrap]

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
    "stealclock.enable"                        = "TRUE"
    "disk.EnableUUID"                          = "TRUE"
    "guestinfo.ignition.config.data"          = var.master_ign_base64
    "guestinfo.ignition.config.data.encoding" = "base64"
    "guestinfo.afterburn.initrd.network-kargs" = "ip=10.0.98.8${count.index + 1}::10.0.98.1:255.255.255.0:master-${count.index}.oc1.cloud.lab:ens192:none nameserver=10.1.102.42"
  }

  tags = var.vm_tags
}
