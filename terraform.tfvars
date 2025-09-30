# Cấu hình cluster
cluster_name = "cp4dddddd"  # Thay đổi tên cluster của bạn ở đây
server_host = "192.168.10.20"
server_user = "root"
server_password = "Amigo@123"
server_ssh_port = 22

# vSphere Configuration (từ install-config.yaml)
vsphere_server = "10.0.55.12"
vsphere_user = "administrator@vsphere.local"
vsphere_password = "VMware1!VMware1!"
vsphere_network = "PG-VLAN195"  # Đã cập nhật từ PG-VLAN198 sang PG-VLAN195
ingress_vip = "10.0.95.19"      # Đã cập nhật từ install-config.yaml
api_vip = "10.0.98.120"
base_domain = "cloud.lab"

# vSphere Infrastructure Details
vsphere_datacenter_name = "Amigo"
vsphere_datastore_name = "AMIGO LAB 02"
vsphere_resource_pool_path = "/Amigo/host/Amigo/Resources"
vsphere_folder = "/Amigo/vm/CPlabs"  # Đã cập nhật từ install-config.yaml

# Template VM name (cần cập nhật theo template thực tế)
template_vm_name = "rhel-8-ocp-template"  # Cần thay đổi theo template thực tế

# Network Configuration
machine_network_cidr = "10.0.98.0/24"
bastion_ip = "192.168.10.20"  # IP của bastion server

# VM Tags (tùy chọn)
vm_tags = ["openshift", "ocp", "kubernetes"]
