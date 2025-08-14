# 🖥️ Self-hosted Runner - VPS Miễn phí với máy của bạn

Hướng dẫn setup self-hosted runner để có VPS mạnh hơn mà vẫn **MIỄN PHÍ**.

## 🎯 **Tại sao dùng Self-hosted Runner?**

### **So sánh:**
| Tính năng | GitHub-hosted | Self-hosted |
|-----------|--------------|-------------|
| **RAM** | 7 GB cố định | **16-64GB+** (tùy máy bạn) |
| **Storage** | 14 GB | **256GB-1TB+** |
| **GPU** | Không có | **RTX 3060/4090** |
| **Thời gian** | 6 tiếng | **Không giới hạn** |
| **Chi phí** | Miễn phí | **Miễn phí** (máy có sẵn) |
| **Tốc độ** | Chậm | **Nhanh hơn** |

## 🔧 **Cách hoạt động:**

```
1. Máy của bạn → Cài GitHub Runner
2. Repository → Settings → Add self-hosted runner  
3. Workflow chạy trên máy của bạn thay vì GitHub
4. Bạn có full control: RAM, GPU, Storage
```

## 💻 **Option 1: Dùng máy tính cá nhân**

### **Yêu cầu tối thiểu:**
- Windows 10/11, macOS, hoặc Linux
- RAM: 8GB+ (khuyến nghị 16GB+)
- Storage: 50GB+ free space
- Internet ổn định

### **Bước 1: Cài đặt Runner**

1. **Vào repository** → **Settings** → **Actions** → **Runners**
2. **Nhấn "New self-hosted runner"**
3. **Chọn OS** (Windows/macOS/Linux)
4. **Copy và chạy commands:**

#### Windows:
```powershell
# Download
mkdir actions-runner; cd actions-runner
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip -OutFile actions-runner-win-x64-2.311.0.zip
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.311.0.zip", "$PWD")

# Configure  
./config.cmd --url https://github.com/YOUR_USERNAME/windows-vps --token YOUR_TOKEN

# Run
./run.cmd
```

#### macOS/Linux:
```bash
# Download
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure
./config.sh --url https://github.com/YOUR_USERNAME/windows-vps --token YOUR_TOKEN

# Run
./run.sh
```

### **Bước 2: Chạy as Service (Optional)**

#### Windows:
```powershell
# Install as Windows Service
./svc.sh install
./svc.sh start
```

#### Linux:  
```bash
# Install as systemd service
sudo ./svc.sh install
sudo ./svc.sh start
```

## 🖥️ **Option 2: VPS rẻ làm runner**

### **Thuê VPS rẻ:**
- **Contabo**: $4.99/tháng (4 vCPU, 8GB RAM, 200GB SSD)
- **Vultr**: $6/tháng (2 vCPU, 4GB RAM, 80GB SSD)  
- **DigitalOcean**: $6/tháng (1 vCPU, 2GB RAM, 50GB SSD)

### **Setup trên VPS:**
```bash
# 1. SSH vào VPS
ssh root@your-vps-ip

# 2. Update system
apt update && apt upgrade -y

# 3. Install dependencies
apt install -y curl wget git

# 4. Create user for runner
useradd -m -s /bin/bash runner
su - runner

# 5. Download và setup runner (như bước 1)
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
./config.sh --url https://github.com/YOUR_USERNAME/windows-vps --token YOUR_TOKEN

# 6. Run as service
sudo ./svc.sh install runner
sudo ./svc.sh start
```

## 🔧 **Option 3: Máy cũ/Server tại nhà**

### **Biến máy cũ thành runner:**
1. **Cài Ubuntu Server** trên máy cũ
2. **Setup runner** như Option 2
3. **Để chạy 24/7** tại nhà
4. **Port forwarding** nếu cần truy cập từ ngoài

### **Docker setup:**
```bash
# 1. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Run runner in Docker
docker run -d \
  --name github-runner \
  --restart unless-stopped \
  -e REPO_URL="https://github.com/YOUR_USERNAME/windows-vps" \
  -e RUNNER_NAME="home-server" \
  -e RUNNER_TOKEN="YOUR_TOKEN" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  myoung34/github-runner:latest
```

## 🎮 **GPU Support cho AI/ML**

### **Nếu máy có GPU:**
```bash
# 1. Install NVIDIA drivers
sudo apt install nvidia-driver-470

# 2. Install CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda-repo-ubuntu2004-11-4-local_11.4.0-470.42.01-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-4-local_11.4.0-470.42.01-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-4-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda

# 3. Install Docker with GPU support
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## ⚙️ **Update workflow để dùng self-hosted**

Workflow sẽ tự động detect và chạy trên runner của bạn:

```yaml
jobs:
  create-vps:
    runs-on: self-hosted  # Thay vì windows-latest
```

## 📊 **Ví dụ cấu hình thực tế:**

### **Máy gaming cá nhân:**
- CPU: Intel i7-12700K (12 cores)
- RAM: 32GB DDR4
- GPU: RTX 4070 (12GB VRAM)
- Storage: 1TB NVMe SSD
- **Chi phí: $0** (máy có sẵn)

### **VPS Contabo $5/tháng:**
- CPU: 4 vCPUs
- RAM: 8GB
- Storage: 200GB SSD
- **Chi phí: $60/năm**

### **Máy cũ tại nhà:**
- CPU: Intel i5-8400 (6 cores)
- RAM: 16GB DDR4
- Storage: 500GB SSD
- **Chi phí: $0** (tái sử dụng)

## 🛡️ **Bảo mật:**

### **Best practices:**
- Chạy runner với user riêng (không root)
- Firewall chặn ports không cần thiết
- Auto-update OS và dependencies
- Monitor resource usage

### **Network security:**
- Runner chỉ kết nối outbound đến GitHub
- Không cần port forwarding
- VPN nếu muốn bảo mật cao hơn

## 💡 **Tips tối ưu:**

1. **SSD**: Dùng SSD thay vì HDD (nhanh hơn 10x)
2. **RAM**: 16GB+ cho development, 32GB+ cho AI/ML
3. **Internet**: Cáp mạng ổn định (không WiFi)
4. **Cooling**: Đảm bảo tản nhiệt tốt cho chạy 24/7
5. **UPS**: Nguồn lưu điện để tránh mất điện

## ❓ **FAQ:**

**Q: Runner có tốn điện không?**
A: Có, nhưng không nhiều (~50-100W). Chi phí điện ~$5-10/tháng.

**Q: Có thể tắt máy không?**  
A: Được, nhưng workflow sẽ fail nếu runner offline.

**Q: Có thể dùng nhiều runners?**
A: Được! Có thể add nhiều máy làm runners.

**Q: Bảo mật như nào?**
A: Runner chỉ kết nối outbound, không có inbound connections.

**Q: Có thể chạy Windows trên Linux runner?**
A: Có, dùng Docker với Windows containers hoặc VM.

## 🎉 **Kết luận:**

Self-hosted runner cho phép bạn:
- ✅ **Miễn phí** (dùng máy có sẵn)
- ✅ **Cấu hình mạnh** (16-64GB RAM, GPU)
- ✅ **Không giới hạn thời gian**
- ✅ **Tốc độ nhanh** (máy local)
- ✅ **Full control** (cài đặt gì cũng được)

Chỉ cần 1 máy tính bình thường là có thể tạo "VPS" mạnh hơn GitHub Actions!

---

*Cần hỗ trợ setup? Tạo issue trên GitHub repository.*
