# Data source để đọc base64 encoded ignition files
data "external" "ignition_data" {
  depends_on = [null_resource.bastion_setup]
  
  program = ["bash", "-c", <<-EOT
    cd /home/${var.cluster_name}
    
    # Đọc base64 encoded files
    BOOTSTRAP_B64=$(cat bootstrap.ign.base64 2>/dev/null || echo "")
    MASTER_B64=$(cat master.ign.base64 2>/dev/null || echo "")
    WORKER_B64=$(cat worker.ign.base64 2>/dev/null || echo "")
    
    # Tạo JSON output
    cat << EOF
    {
      "bootstrap_base64": "$BOOTSTRAP_B64",
      "master_base64": "$MASTER_B64", 
      "worker_base64": "$WORKER_B64"
    }
    EOF
  EOT
  ]
}

# Output guestinfo parameters cho vSphere VMs
output "guestinfo_parameters" {
  description = "Guestinfo parameters cho vSphere VMs"
  value = {
    bootstrap = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.bootstrap_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
    master = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.master_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
    worker = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.worker_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
  }
}

# Output bootstrap URL cho reference
output "bootstrap_ignition_url" {
  description = "URL cho bootstrap ignition file"
  value       = "http://${var.server_host}/ocp-bootstrap-deploy/${var.cluster_name}/bootstrap.ign"
}

# Output để copy/paste vào vSphere VM settings
output "vsphere_vm_settings" {
  description = "Settings để copy vào vSphere VM Advanced Parameters"
  value = {
    bootstrap_vm = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.bootstrap_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
    master_vm = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.master_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
    worker_vm = {
      "guestinfo.ignition.config.data"          = data.external.ignition_data.result.worker_base64
      "guestinfo.ignition.config.data.encoding" = "base64"
    }
  }
}
