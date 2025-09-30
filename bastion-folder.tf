# Local variable cho SSH connection
locals {
  ssh_connection = {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Thiết lập SSH và thực thi các bước trong một resource để tái sử dụng connection
resource "null_resource" "bastion_setup" {
  # Kích hoạt lại khi đổi tên cluster hoặc nội dung template thay đổi
  triggers = {
    cluster_name = var.cluster_name
    config_hash = md5(templatefile("${path.module}/install-config.yaml", {
      cluster_name         = var.cluster_name
      base_domain          = var.base_domain
      machine_network_cidr = var.machine_network_cidr
      service_network_cidr = var.service_network_cidr
      api_vip              = var.api_vip
      ingress_vip          = var.ingress_vip
      vsphere_server       = var.vsphere_server
      vsphere_user         = var.vsphere_user
      vsphere_password     = var.vsphere_password
      vsphere_network      = var.vsphere_network
    }))
  }

  # 1) Tạo folder trên máy bastion
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.cluster_name}",
      "chmod 755 /home/${var.cluster_name}",
      "echo 'Folder ${var.cluster_name} created successfully'"
    ]
  }

  # 2) Ghi file install-config.yaml từ template
  provisioner "remote-exec" {
    inline = [
      "cat > /home/${var.cluster_name}/install-config.yaml << 'EOF'",
      templatefile("${path.module}/install-config.yaml", {
        cluster_name         = var.cluster_name
        base_domain          = var.base_domain
        machine_network_cidr = var.machine_network_cidr
        service_network_cidr = var.service_network_cidr
        api_vip              = var.api_vip
        ingress_vip          = var.ingress_vip
        vsphere_server       = var.vsphere_server
        vsphere_user         = var.vsphere_user
        vsphere_password     = var.vsphere_password
        vsphere_network      = var.vsphere_network
      }),
      "EOF",
      "chmod 644 /home/${var.cluster_name}/install-config.yaml",
      "echo 'install-config.yaml created successfully in /home/${var.cluster_name}/'"
    ]
  }
  # 2.5) Backup file install-config.yaml vừa tạo
  provisioner "remote-exec" {
    inline = [
      "BK=/home/${var.cluster_name}/install_config_backup",
      "mkdir -p $BK",
      "cp -f /home/${var.cluster_name}/install-config.yaml $BK/install-config.yaml.$(date +%Y%m%d-%H%M%S)",
      "echo 'Backed up new install-config.yaml to ' $BK"
    ]
  }
  # 3) Sinh ignition configs trực tiếp vào folder của cluster
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "openshift-install create ignition-configs --dir=/home/${var.cluster_name}",
      "ls -l /home/${var.cluster_name} | grep -E 'bootstrap.ign|master.ign|worker.ign' || true",
      "echo 'Ignition files generated in /home/${var.cluster_name}'"
    ]
  }

  # 4) Tạo thư mục web server và copy bootstrap.ign
  provisioner "remote-exec" {
    inline = [
      "WEB_DIR=\"/var/www/html/ocp-bootstrap-deploy/${var.cluster_name}\"",
      "mkdir -p $WEB_DIR",
      "cp /home/${var.cluster_name}/bootstrap.ign $WEB_DIR/bootstrap.ign",
      "chmod 644 $WEB_DIR/bootstrap.ign",
      "echo 'Bootstrap ignition file copied to web server: $WEB_DIR/bootstrap.ign'"
    ]
  }

  # 5) Base64 encode các file ignition và lưu vào file
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.cluster_name}",
      "echo 'Base64 encoding ignition files...'",
      "base64 -w 0 bootstrap.ign > bootstrap.ign.base64",
      "base64 -w 0 master.ign > master.ign.base64", 
      "base64 -w 0 worker.ign > worker.ign.base64",
      "echo 'Base64 encoded files created:'",
      "ls -l *.ign.base64",
      "echo 'Bootstrap URL: http://${var.server_host}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign'"
    ]
  }

  # Kết nối SSH áp dụng cho cả hai provisioners phía trên
  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Output thông tin folder đã tạo
output "cluster_folder_path" {
  description = "Đường dẫn folder cluster đã tạo"
  value       = "/home/${var.cluster_name}"
}

output "install_config_path" {
  description = "Đường dẫn file install-config.yaml"
  value       = "/home/${var.cluster_name}/install-config.yaml"
}

output "bootstrap_url" {
  description = "URL để download bootstrap.ign"
  value       = "http://${var.server_host}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
}

output "ignition_files_path" {
  description = "Đường dẫn các file ignition"
  value = {
    bootstrap = "/home/${var.cluster_name}/bootstrap.ign"
    master    = "/home/${var.cluster_name}/master.ign"
    worker    = "/home/${var.cluster_name}/worker.ign"
    base64_bootstrap = "/home/${var.cluster_name}/bootstrap.ign.base64"
    base64_master    = "/home/${var.cluster_name}/master.ign.base64"
    base64_worker    = "/home/${var.cluster_name}/worker.ign.base64"
  }
}

output "web_server_path" {
  description = "Đường dẫn web server cho bootstrap.ign"
  value       = "/var/www/html/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
}

output "server_info" {
  description = "Thông tin server"
  value = {
    host = var.server_host
    user = var.server_user
    folder_created = "/home/${var.cluster_name}"
    install_config = "/home/${var.cluster_name}/install-config.yaml"
    bootstrap_url = "http://${var.server_host}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
  }
}


