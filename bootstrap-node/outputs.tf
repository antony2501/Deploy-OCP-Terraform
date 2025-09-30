# ====== BOOTSTRAP NODE OUTPUTS ======

output "bootstrap_vm_name" {
  description = "Name of the bootstrap VM"
  value       = vsphere_virtual_machine.bootstrap.name
}

output "bootstrap_vm_id" {
  description = "ID of the bootstrap VM"
  value       = vsphere_virtual_machine.bootstrap.id
}

output "master_vm_names" {
  description = "Names of the master VMs"
  value       = vsphere_virtual_machine.master[*].name
}

output "master_vm_ids" {
  description = "IDs of the master VMs"
  value       = vsphere_virtual_machine.master[*].id
}

output "worker_vm_names" {
  description = "Names of the worker VMs"
  value       = vsphere_virtual_machine.worker[*].name
}

output "worker_vm_ids" {
  description = "IDs of the worker VMs"
  value       = vsphere_virtual_machine.worker[*].id
}

output "all_vm_names" {
  description = "All VM names (bootstrap + master + worker)"
  value = concat(
    [vsphere_virtual_machine.bootstrap.name],
    vsphere_virtual_machine.master[*].name,
    vsphere_virtual_machine.worker[*].name
  )
}

output "all_vm_ids" {
  description = "All VM IDs (bootstrap + master + worker)"
  value = concat(
    [vsphere_virtual_machine.bootstrap.id],
    vsphere_virtual_machine.master[*].id,
    vsphere_virtual_machine.worker[*].id
  )
}

output "vm_ip_addresses" {
  description = "IP addresses of all VMs"
  value = {
    bootstrap = "10.0.98.80"
    masters   = ["10.0.98.81", "10.0.98.82", "10.0.98.83"]
    workers   = [for i in range(var.worker_count) : "10.0.98.9${i}"]
  }
}

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    cluster_name    = var.cluster_name
    bootstrap_vm    = vsphere_virtual_machine.bootstrap.name
    master_count    = length(vsphere_virtual_machine.master)
    worker_count    = length(vsphere_virtual_machine.worker)
    total_vms       = 1 + length(vsphere_virtual_machine.master) + length(vsphere_virtual_machine.worker)
    vsphere_folder  = var.vsphere_folder
    network         = var.vsphere_portgroup_name
  }
}
