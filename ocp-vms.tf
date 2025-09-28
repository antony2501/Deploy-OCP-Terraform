# Create Bootstrap VM
resource "vsphere_virtual_machine" "bootstrap" {
  depends_on = [null_resource.generate_ignition]
  
  name             = "${var.cluster_name}-bootstrap"
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder           = var.folder

  num_cpus = 4
  memory   = 16384
  guest_id = "rhel8_64Guest"

  scsi_type = "pvscsi"

  network_interface {
    network_id   = var.network_id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = var.ova_name
  }

  extra_config = {
    "guestinfo.ignition.config.data"          = base64encode(file("${path.module}/bootstrap.ign"))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }

  tags = ["openshift", "bootstrap", var.cluster_name]
}

# Create Control Plane VMs
resource "vsphere_virtual_machine" "control_plane" {
  count = 3
  
  depends_on = [null_resource.generate_ignition]
  
  name             = "${var.cluster_name}-master-${count.index}"
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder           = var.folder

  num_cpus = 4
  memory   = 16384
  guest_id = "rhel8_64Guest"

  scsi_type = "pvscsi"

  network_interface {
    network_id   = var.network_id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = var.ova_name
  }

  extra_config = {
    "guestinfo.ignition.config.data"          = base64encode(file("${path.module}/master.ign"))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }

  tags = ["openshift", "master", var.cluster_name]
}

# Create Worker VMs (optional - có thể tạo sau)
resource "vsphere_virtual_machine" "worker" {
  count = var.worker_count
  
  depends_on = [null_resource.generate_ignition]
  
  name             = "${var.cluster_name}-worker-${count.index}"
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder           = var.folder

  num_cpus = 2
  memory   = 8192
  guest_id = "rhel8_64Guest"

  scsi_type = "pvscsi"

  network_interface {
    network_id   = var.network_id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = var.ova_name
  }

  extra_config = {
    "guestinfo.ignition.config.data"          = base64encode(file("${path.module}/worker.ign"))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }

  tags = ["openshift", "worker", var.cluster_name]
}

# Output VM information
output "bootstrap_vm_name" {
  description = "Tên Bootstrap VM"
  value       = vsphere_virtual_machine.bootstrap.name
}

output "control_plane_vms" {
  description = "Danh sách Control Plane VMs"
  value       = vsphere_virtual_machine.control_plane[*].name
}

output "worker_vms" {
  description = "Danh sách Worker VMs"
  value       = vsphere_virtual_machine.worker[*].name
}
