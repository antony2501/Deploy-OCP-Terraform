# Hướng dẫn Deploy OpenShift Cluster theo từng bước

## Cấu trúc file sau khi tách:
- `data-sources.tf` - Data sources chung cho tất cả VMs
- `bootstrap-vm.tf` - Bootstrap VM
- `bootstrap-wait.tf` - Wait resource để đảm bảo bootstrap VM khởi động hoàn toàn
- `master-vms.tf` - Master/Control Plane VMs (phụ thuộc vào bootstrap)
- `worker-vms.tf` - Worker VMs (phụ thuộc vào bootstrap)

## Các bước deploy:

### 🚀 Cách 1: Deploy tự động với depends_on (Khuyến nghị)
```bash
# Deploy tất cả cùng lúc - Terraform sẽ tự động đảm bảo thứ tự
terraform plan
terraform apply

# Terraform sẽ tự động:
# 1. Tạo bootstrap VM trước
# 2. Đợi 2 phút để bootstrap VM khởi động hoàn toàn  
# 3. Tạo master VMs
# 4. Tạo worker VMs
```

### 🔧 Cách 2: Deploy từng bước thủ công
```bash
# Bước 1: Deploy Bootstrap VM
terraform plan -target=vsphere_virtual_machine.bootstrap
terraform apply -target=vsphere_virtual_machine.bootstrap

# Bước 2: Deploy Bootstrap Wait (tùy chọn nếu muốn kiểm soát thời gian)
terraform plan -target=time_sleep.wait_for_bootstrap
terraform apply -target=time_sleep.wait_for_bootstrap

# Bước 3: Deploy Master VMs
terraform plan -target=vsphere_virtual_machine.master
terraform apply -target=vsphere_virtual_machine.master

# Bước 4: Deploy Worker VMs
terraform plan -target=vsphere_virtual_machine.worker
terraform apply -target=vsphere_virtual_machine.worker
```

### Bước 2: Kiểm tra Bootstrap VM
```bash
# Kiểm tra trạng thái bootstrap VM
terraform show | grep bootstrap

# SSH vào bootstrap VM để kiểm tra
ssh core@10.0.98.80

# Kiểm tra logs bootstrap
ssh core@10.0.98.80 "journalctl -u bootkube.service -f"
```

### Bước 3: Deploy Master VMs
```bash
# Deploy master VMs
terraform plan -target=vsphere_virtual_machine.master
terraform apply -target=vsphere_virtual_machine.master

# Hoặc sử dụng file cụ thể
mv bootstrap-vm.tf bootstrap-vm.tf.bak
mv worker-vms.tf worker-vms.tf.bak
terraform plan
terraform apply
mv bootstrap-vm.tf.bak bootstrap-vm.tf
mv worker-vms.tf.bak worker-vms.tf
```

### Bước 4: Kiểm tra Master VMs
```bash
# Kiểm tra trạng thái master VMs
terraform show | grep master

# SSH vào từng master VM
ssh core@10.0.98.81
ssh core@10.0.98.82  
ssh core@10.0.98.83

# Kiểm tra etcd cluster
ssh core@10.0.98.81 "etcdctl member list"
```

### Bước 5: Deploy Worker VMs
```bash
# Deploy worker VMs
terraform plan -target=vsphere_virtual_machine.worker
terraform apply -target=vsphere_virtual_machine.worker

# Hoặc sử dụng file cụ thể
mv bootstrap-vm.tf bootstrap-vm.tf.bak
mv master-vms.tf master-vms.tf.bak
terraform plan
terraform apply
mv bootstrap-vm.tf.bak bootstrap-vm.tf
mv master-vms.tf.bak master-vms.tf
```

### Bước 6: Kiểm tra Worker VMs
```bash
# Kiểm tra trạng thái worker VMs
terraform show | grep worker

# SSH vào worker VMs
ssh core@10.0.98.90
ssh core@10.0.98.91
# ... tùy theo số lượng worker

# Kiểm tra node status từ master
ssh core@10.0.98.81 "oc get nodes"
```

## Lưu ý quan trọng:

### 🔗 Dependency Chain:
```
bootstrap-vm.tf → bootstrap-wait.tf → master-vms.tf + worker-vms.tf
```

1. **Bootstrap VM**: Chạy tạm thời để khởi tạo cluster, có thể xóa sau khi cluster hoàn thành
2. **Bootstrap Wait**: Đợi 2 phút để bootstrap VM khởi động hoàn toàn trước khi tạo master/worker
3. **Master VMs**: Phải có ít nhất 3 nodes để đảm bảo HA cho etcd, phụ thuộc vào bootstrap
4. **Worker VMs**: Có thể thêm/bớt tùy theo nhu cầu, phụ thuộc vào bootstrap
5. **IP Addressing**: 
   - Bootstrap: 10.0.98.80
   - Master: 10.0.98.81-83
   - Worker: 10.0.98.90+

### ⚡ Với depends_on:
- **Tự động**: Terraform tự động đảm bảo thứ tự deployment
- **An toàn**: Không cần can thiệp thủ công
- **Hiệu quả**: Có thể deploy tất cả cùng lúc với `terraform apply`

## Troubleshooting:

### Nếu bootstrap VM không start được:
```bash
# Kiểm tra ignition config
curl -I http://10.0.98.80/ocp-bootstrap-deploy/your-cluster/bootstrap.ign

# Kiểm tra network connectivity
ping 10.0.98.80
```

### Nếu master VMs không join cluster:
```bash
# Kiểm tra ignition data
echo $MASTER_IGN_BASE64 | base64 -d

# Kiểm tra network
ping 10.0.98.81
```

### Xóa bootstrap VM sau khi cluster hoàn thành:
```bash
terraform destroy -target=vsphere_virtual_machine.bootstrap
```
