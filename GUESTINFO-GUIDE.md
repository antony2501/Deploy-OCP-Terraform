# Hướng dẫn sử dụng Guestinfo Parameters cho vSphere VMs

## Tổng quan
Sau khi chạy `terraform apply`, các file ignition đã được tạo và base64 encoded. Bạn có thể sử dụng các giá trị này để cấu hình vSphere VMs.

## Các bước thực hiện:

### 1. Chạy Terraform để tạo ignition files
```bash
terraform apply
```

### 2. Lấy guestinfo parameters
```bash
terraform output guestinfo_parameters
```

### 3. Cấu hình vSphere VMs

#### Bootstrap VM:
- **Name**: `{cluster_name}-bootstrap`
- **Advanced Parameters**:
  ```
  guestinfo.ignition.config.data = [bootstrap_base64_value]
  guestinfo.ignition.config.data.encoding = base64
  ```

#### Master VMs (3 nodes):
- **Name**: `{cluster_name}-master-0`, `{cluster_name}-master-1`, `{cluster_name}-master-2`
- **Advanced Parameters**:
  ```
  guestinfo.ignition.config.data = [master_base64_value]
  guestinfo.ignition.config.data.encoding = base64
  ```

#### Worker VMs (3 nodes):
- **Name**: `{cluster_name}-worker-0`, `{cluster_name}-worker-1`, `{cluster_name}-worker-2`
- **Advanced Parameters**:
  ```
  guestinfo.ignition.config.data = [worker_base64_value]
  guestinfo.ignition.config.data.encoding = base64
  ```

## Files được tạo:

### Trên Bastion Server:
- `/home/{cluster_name}/bootstrap.ign` - Bootstrap ignition file
- `/home/{cluster_name}/master.ign` - Master ignition file
- `/home/{cluster_name}/worker.ign` - Worker ignition file
- `/home/{cluster_name}/bootstrap.ign.base64` - Base64 encoded bootstrap
- `/home/{cluster_name}/master.ign.base64` - Base64 encoded master
- `/home/{cluster_name}/worker.ign.base64` - Base64 encoded worker

### Web Server:
- `/var/www/html/ocp-bootstrap-deploy/{cluster_name}/bootstrap.ign`
- URL: `http://{server_host}/ocp-bootstrap-deploy/{cluster_name}/bootstrap.ign`

## Cách lấy base64 values:

### Từ Terraform output:
```bash
terraform output -json guestinfo_parameters
```

### Từ bastion server:
```bash
ssh root@{server_host}
cd /home/{cluster_name}
cat bootstrap.ign.base64
cat master.ign.base64
cat worker.ign.base64
```

## Lưu ý quan trọng:

1. **Bootstrap VM** cần được khởi động trước
2. **Master VMs** khởi động sau bootstrap
3. **Worker VMs** có thể khởi động song song với master
4. **Bootstrap VM** sẽ tự động shutdown sau khi cluster ready
5. Đảm bảo **web server** đang chạy để serve bootstrap.ign

## Troubleshooting:

### Kiểm tra web server:
```bash
curl http://{server_host}/ocp-bootstrap-deploy/{cluster_name}/bootstrap.ign
```

### Kiểm tra ignition files:
```bash
ssh root@{server_host}
ls -la /home/{cluster_name}/*.ign*
```

### Kiểm tra base64 encoding:
```bash
ssh root@{server_host}
cd /home/{cluster_name}
base64 -d bootstrap.ign.base64 | jq .
```
