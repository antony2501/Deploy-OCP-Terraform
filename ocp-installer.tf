# Download OpenShift installer
resource "null_resource" "download_openshift_installer" {
  depends_on = [null_resource.copy_install_config]
  
  triggers = {
    cluster_name = var.cluster_name
    openshift_version = var.openshift_version
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Downloading OpenShift installer version ${var.openshift_version}...'",
      "wget -O openshift-install-linux.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${var.openshift_version}/openshift-install-linux.tar.gz",
      "tar -xzf openshift-install-linux.tar.gz",
      "chmod +x openshift-install",
      "rm openshift-install-linux.tar.gz",
      "echo 'OpenShift installer downloaded successfully'"
    ]
  }

  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Generate manifests and ignition files
resource "null_resource" "generate_manifests" {
  depends_on = [null_resource.download_openshift_installer]
  
  triggers = {
    cluster_name = var.cluster_name
    config_hash = md5(templatefile("${path.module}/install-config.yaml", {
      cluster_name         = var.cluster_name
      base_domain         = var.base_domain
      machine_network_cidr = var.machine_network_cidr
      service_network_cidr = var.service_network_cidr
      api_vip             = var.api_vip
      ingress_vip         = var.ingress_vip
      vsphere_server      = var.vsphere_server
      vsphere_user        = var.vsphere_user
      vsphere_password    = var.vsphere_password
      vsphere_network     = var.vsphere_network
    }))
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Generating manifests and ignition files...'",
      "./openshift-install create manifests --dir=/home/${var.cluster_name}",
      "echo 'Manifests generated successfully'"
    ]
  }

  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Generate ignition configs
resource "null_resource" "generate_ignition" {
  depends_on = [null_resource.generate_manifests]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Generating ignition configs...'",
      "./openshift-install create ignition-configs --dir=/home/${var.cluster_name}",
      "echo 'Ignition configs generated successfully'",
      "ls -la /home/${var.cluster_name}/"
    ]
  }

  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Output paths
output "installer_path" {
  description = "Đường dẫn OpenShift installer"
  value       = "/home/${var.cluster_name}/openshift-install"
}

output "ignition_files_path" {
  description = "Đường dẫn thư mục chứa ignition files"
  value       = "/home/${var.cluster_name}"
}

output "bootstrap_ignition_url" {
  description = "URL cho bootstrap ignition file"
  value       = "http://${var.server_host}:8080/bootstrap.ign"
}
