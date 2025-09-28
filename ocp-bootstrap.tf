# Start HTTP server for ignition files
resource "null_resource" "start_http_server" {
  depends_on = [null_resource.generate_ignition]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Starting HTTP server for ignition files...'",
      "nohup python3 -m http.server 8080 > /dev/null 2>&1 &",
      "echo 'HTTP server started on port 8080'",
      "sleep 5"
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

# Wait for bootstrap to complete
resource "null_resource" "wait_for_bootstrap" {
  depends_on = [vsphere_virtual_machine.bootstrap, null_resource.start_http_server]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Waiting for bootstrap to complete...'",
      "echo 'This may take 10-15 minutes...'",
      "./openshift-install wait-for bootstrap-complete --dir=/home/${var.cluster_name} --log-level=info"
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

# Destroy bootstrap VM after bootstrap completes
resource "null_resource" "destroy_bootstrap" {
  depends_on = [null_resource.wait_for_bootstrap]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Bootstrap completed. Destroying bootstrap VM...'",
      "echo 'Bootstrap VM will be destroyed by Terraform'"
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

# Wait for cluster installation to complete
resource "null_resource" "wait_for_install_complete" {
  depends_on = [null_resource.destroy_bootstrap]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Waiting for cluster installation to complete...'",
      "echo 'This may take 30-45 minutes...'",
      "./openshift-install wait-for install-complete --dir=/home/${var.cluster_name} --log-level=info"
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

# Get cluster credentials
resource "null_resource" "get_credentials" {
  depends_on = [null_resource.wait_for_install_complete]
  
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Getting cluster credentials...'",
      "export KUBECONFIG=/home/${var.cluster_name}/auth/kubeconfig",
      "echo 'Cluster installation completed successfully!'",
      "echo 'Kubeconfig location: /home/${var.cluster_name}/auth/kubeconfig'",
      "echo 'Web console URL: https://console-openshift-console.apps.${var.cluster_name}.${var.base_domain}'",
      "echo 'API URL: https://api.${var.cluster_name}.${var.base_domain}:6443'"
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

# Output cluster information
output "cluster_console_url" {
  description = "OpenShift Web Console URL"
  value       = "https://console-openshift-console.apps.${var.cluster_name}.${var.base_domain}"
}

output "cluster_api_url" {
  description = "OpenShift API URL"
  value       = "https://api.${var.cluster_name}.${var.base_domain}:6443"
}

output "kubeconfig_path" {
  description = "Đường dẫn kubeconfig file"
  value       = "/home/${var.cluster_name}/auth/kubeconfig"
}

output "cluster_admin_credentials" {
  description = "Cluster admin credentials"
  value       = "/home/${var.cluster_name}/auth/kubeadmin-password"
  sensitive   = true
}
