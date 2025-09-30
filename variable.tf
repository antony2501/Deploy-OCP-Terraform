

# Variables cho server và folder creation
variable "cluster_name" {
  description = "Tên cluster - sẽ được dùng để tạo folder"
  type        = string
}

variable "server_host" {
  description = "IP của server"
  type        = string
  default     = "192.168.10.20"
}

variable "server_user" {
  description = "Username để SSH vào server"
  type        = string
  default     = "root"
}

variable "server_password" {
  description = "Password để SSH vào server"
  type        = string
  default     = "Amigo@123"
}

variable "server_ssh_port" {
  description = "SSH port của server"
  type        = number
  default     = 22
}

# Variables cho install-config.yaml
variable "base_domain" {
  description = "Base domain cho OpenShift cluster"
  type        = string
  default     = "cloud.lab"
}

variable "machine_network_cidr" {
  description = "Machine network CIDR"
  type        = string
  default     = "10.0.98.0/24"
}

variable "service_network_cidr" {
  description = "Service network CIDR"
  type        = string
  default     = "172.30.0.0/16"
}

variable "api_vip" {
  description = "API VIP address"
  type        = string
}

variable "ingress_vip" {
  description = "Ingress VIP address"
  type        = string
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
  default     = "10.0.55.12"
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  default     = "administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
  default     = "VMware1!VMware1!"
}

variable "vsphere_network" {
  description = "vSphere network name"
  type        = string
  default     = "PG-VLAN195"
}

# vSphere Infrastructure Variables
variable "vsphere_datacenter_name" {
  description = "vSphere datacenter name"
  type        = string
  default     = "Amigo"
}

variable "vsphere_datastore_name" {
  description = "vSphere datastore name"
  type        = string
  default     = "AMIGO LAB 02"
}

variable "vsphere_resource_pool_path" {
  description = "vSphere resource pool path"
  type        = string
  default     = "/Amigo/host/Amigo/Resources"
}

variable "vsphere_folder" {
  description = "vSphere folder path for VMs"
  type        = string
  default     = "/Amigo/vm/CPlabs"
}

variable "template_vm_name" {
  description = "Name of the template VM to clone from"
  type        = string
  default     = "rhel-8-ocp-template"
}

variable "bastion_ip" {
  description = "IP address of the bastion server"
  type        = string
  default     = "192.168.10.20"
}

variable "vm_tags" {
  description = "Tags to apply to VMs"
  type        = list(string)
  default     = ["openshift", "ocp", "kubernetes"]
}

# Ignition configuration variables (cần được tạo từ OpenShift installer)
variable "master_ign_base64" {
  description = "Base64 encoded master ignition configuration"
  type        = string
  default     = ""
}

variable "worker_ign_base64" {
  description = "Base64 encoded worker ignition configuration"
  type        = string
  default     = ""
}

variable "bootstrap_ign_sha256" {
  description = "SHA256 checksum of bootstrap ignition configuration"
  type        = string
  default     = ""
}

variable "openshift_install_version" {
  description = "OpenShift installer version to use (allowed: 4-16-20, 4-17-2, 4-18-10)"
  type        = string
  default     = "4-16-20"
  validation {
    condition = contains(["4-16-20", "4-17-2", "4-18-10"], var.openshift_install_version)
    error_message = "openshift_install_version must be one of: 4-16-20, 4-17-2, 4-18-10."
  }
}

# Optional explicit path/name for the installer on bastion. If empty, derived from version.
variable "openshift_install_binary" {
  description = "Name or absolute path of the openshift-install binary on the bastion host"
  type        = string
  default     = ""
}

