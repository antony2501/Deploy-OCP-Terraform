# ====== BOOTSTRAP NODE DEPLOYMENT ======
# Module để deploy bootstrap, master và worker VMs

module "bootstrap_nodes" {
  source = "./bootstrap-node"
  
  # Cluster configuration
  cluster_name = var.cluster_name
  worker_count = 3  # Số lượng worker nodes
  
  # vSphere configuration
  vsphere_datacenter_name   = var.vsphere_datacenter_name
  vsphere_datastore_name    = var.vsphere_datastore_name
  vsphere_portgroup_name    = var.vsphere_network  # Mapping từ vsphere_network
  vsphere_resource_pool_path = var.vsphere_resource_pool_path
  vsphere_folder            = var.vsphere_folder
  template_vm_name          = var.template_vm_name
  
  # Network configuration
  bastion_ip = var.bastion_ip
  
  # VM tags
  vm_tags = var.vm_tags
  
  # Ignition configurations (cần được tạo từ OpenShift installer)
  # Lưu ý: Các giá trị này cần được cung cấp sau khi chạy openshift-install
  master_ign_base64 = var.master_ign_base64
  worker_ign_base64 = var.worker_ign_base64
  bootstrap_ign_sha256 = var.bootstrap_ign_sha256
  
  depends_on = [
    # Đảm bảo vSphere data sources đã được tạo
    data.vsphere_datacenter.dc,
    data.vsphere_datastore.ds,
    data.vsphere_network.net,
    data.vsphere_resource_pool.rp,
    data.vsphere_virtual_machine.template
  ]
}

# ====== OUTPUTS ======
# Output thông tin về các VMs đã được tạo

output "bootstrap_vm_info" {
  description = "Thông tin Bootstrap VM"
  value = {
    name = module.bootstrap_nodes.bootstrap_vm_name
    ip   = "10.0.98.80"  # IP cố định theo cấu hình
  }
}

output "master_vms_info" {
  description = "Thông tin Master VMs"
  value = {
    count = 3
    names = module.bootstrap_nodes.master_vm_names
    ips   = ["10.0.98.81", "10.0.98.82", "10.0.98.83"]
  }
}

output "worker_vms_info" {
  description = "Thông tin Worker VMs"
  value = {
    count = 3
    names = module.bootstrap_nodes.worker_vm_names
    ips   = ["10.0.98.90", "10.0.98.91", "10.0.98.92"]
  }
}

output "deployment_summary" {
  description = "Tóm tắt deployment"
  value = {
    cluster_name    = var.cluster_name
    vsphere_server  = var.vsphere_server
    datacenter      = var.vsphere_datacenter_name
    folder          = var.vsphere_folder
    total_vms       = 7  # 1 bootstrap + 3 master + 3 worker
    network         = var.vsphere_network
    api_vip         = var.api_vip
    ingress_vip     = var.ingress_vip
  }
}
