variable "cluster_name" { type = string }

# vSphere lookups
variable "vsphere_datacenter_name"  { type = string }
variable "vsphere_datastore_name"   { type = string }
variable "vsphere_portgroup_name"   { type = string }
variable "vsphere_resource_pool_path" { type = string } # ví dụ: "/Amigo/host/Amigo/Resources"
variable "vsphere_folder"           { type = string }   # ví dụ: "/Amigo/vm/OCP-agent-base"
variable "template_vm_name"         { type = string }   # tên template VM đã tạo từ OVA

# Bastion + bootstrap URL
variable "bastion_ip" { type = string }                 # ví dụ: "192.168.10.20"
# variable "bootstrap_ign_sha256" { type = string, default = "" } # tùy chọn

# Ignition base64 (đã encode trước hoặc lấy từ Terraform output bạn đã tạo)
variable "master_ign_base64" { type = string }
variable "worker_ign_base64" { type = string }

# Tag tuỳ chọn
variable "vm_tags" {
  type    = list(string)
  default = ["openshift"]
}

variable "worker_count" {
  type    = number
  default = 3
}