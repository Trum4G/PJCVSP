# ☁️ Hướng dẫn Setup Cloud VPS (Azure/AWS)

Tài liệu này hướng dẫn cách setup VPS mạnh hơn trên Azure và AWS với cấu hình cao.

## 🎯 So sánh các options

| Tính năng | GitHub Actions | Azure VPS | AWS VPS |
|-----------|---------------|-----------|---------|
| **Chi phí** | MIỄN PHÍ | ~$0.5-2/giờ | ~$0.4-3/giờ |
| **RAM** | 7 GB | 16-112 GB | 16-61 GB |
| **Storage** | 14 GB | 256 GB SSD | 256 GB SSD |
| **GPU** | Không | Tesla K80 | Tesla V100/T4 |
| **Setup** | Dễ | Trung bình | Trung bình |
| **AI/ML** | Hạn chế | Tốt | Rất tốt |

## 🔧 Setup Azure VPS

### Bước 1: Tạo Azure Service Principal

1. **Cài đặt Azure CLI**:
   ```bash
   # Windows
   winget install Microsoft.AzureCLI
   
   # macOS
   brew install azure-cli
   
   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Login vào Azure**:
   ```bash
   az login
   ```

3. **Tạo Service Principal**:
   ```bash
   az ad sp create-for-rbac \
     --name "TASTR-VPS-SP" \
     --role contributor \
     --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
     --sdk-auth
   ```

4. **Copy output JSON** (sẽ dùng trong GitHub Secrets):
   ```json
   {
     "clientId": "xxx-xxx-xxx",
     "clientSecret": "xxx-xxx-xxx", 
     "subscriptionId": "xxx-xxx-xxx",
     "tenantId": "xxx-xxx-xxx"
   }
   ```

### Bước 2: Setup GitHub Secrets

1. Vào repository → **Settings** → **Secrets and variables** → **Actions**
2. Thêm secret mới:
   - **Name**: `AZURE_CREDENTIALS`
   - **Value**: JSON output từ bước 1

### Bước 3: Chạy Azure VPS

1. Vào **Actions** tab
2. Chọn **"Create Azure Windows VPS (High-Spec)"**
3. Chọn VM size:
   - `Standard_D4s_v3`: 4 CPU, 16GB RAM (AI/ML cơ bản)
   - `Standard_NC6`: 6 CPU, 56GB RAM, Tesla K80 GPU (AI/ML nâng cao)
4. Nhấn **"Run workflow"**

## 🔧 Setup AWS VPS  

### Bước 1: Tạo AWS IAM User

1. **Login AWS Console** → IAM → Users → Create user
2. **Username**: `tastr-vps-user`
3. **Attach policies**:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
4. **Create access key** → Command Line Interface (CLI)
5. **Copy Access Key ID và Secret Access Key**

### Bước 2: Setup GitHub Secrets

1. Vào repository → **Settings** → **Secrets and variables** → **Actions**
2. Thêm 2 secrets:
   - **Name**: `AWS_ACCESS_KEY_ID`, **Value**: Your Access Key ID
   - **Name**: `AWS_SECRET_ACCESS_KEY`, **Value**: Your Secret Access Key

### Bước 3: Chạy AWS VPS

1. Vào **Actions** tab
2. Chọn **"Create AWS Windows VPS (High-Spec)"**
3. Chọn instance type:
   - `t3.xlarge`: 4 CPU, 16GB RAM (Development)
   - `g4dn.xlarge`: 4 CPU, 16GB RAM, Tesla T4 GPU (AI/ML)
   - `p3.2xlarge`: 8 CPU, 61GB RAM, Tesla V100 GPU (Heavy AI/ML)
4. Nhấn **"Run workflow"**

## 💰 Ước tính chi phí

### Azure (US East)
| VM Size | CPU | RAM | GPU | Chi phí/giờ | Chi phí/8h |
|---------|-----|-----|-----|-------------|------------|
| Standard_D2s_v3 | 2 | 8GB | None | $0.10 | $0.80 |
| Standard_D4s_v3 | 4 | 16GB | None | $0.20 | $1.60 |
| Standard_NC6 | 6 | 56GB | Tesla K80 | $0.90 | $7.20 |

### AWS (US East)
| Instance Type | CPU | RAM | GPU | Chi phí/giờ | Chi phí/8h |
|---------------|-----|-----|-----|-------------|------------|
| t3.large | 2 | 8GB | None | $0.08 | $0.64 |
| t3.xlarge | 4 | 16GB | None | $0.17 | $1.36 |
| g4dn.xlarge | 4 | 16GB | Tesla T4 | $0.53 | $4.24 |
| p3.2xlarge | 8 | 61GB | Tesla V100 | $3.06 | $24.48 |

## 🎯 Khuyến nghị sử dụng

### Cho học tập (Students)
- **Miễn phí**: GitHub Actions (7GB RAM, CPU only)
- **Có phí**: Azure Standard_D2s_v3 (~$0.80/8h)

### Cho Development  
- **Web/App**: Azure Standard_D4s_v3 (~$1.60/8h)
- **Desktop**: AWS t3.xlarge (~$1.36/8h)

### Cho AI/ML
- **Học AI cơ bản**: AWS g4dn.xlarge (~$4.24/8h)
- **AI nâng cao**: AWS p3.2xlarge (~$24.48/8h)
- **AI với ngân sách thấp**: Azure NC6 (~$7.20/8h)

## 🛡️ Bảo mật

### Azure
- Service Principal có quyền contributor limited
- Resource Group tự động cleanup
- Network Security Group restrict RDP

### AWS  
- IAM User chỉ có quyền EC2 và VPC
- Security Group allow RDP only
- Instance tự động terminate sau timeout

## 🔧 Troubleshooting

### Azure Issues
```bash
# Check subscription
az account show

# List available VM sizes
az vm list-sizes --location "East US"

# Check quotas
az vm list-usage --location "East US"
```

### AWS Issues
```bash
# Check credentials
aws sts get-caller-identity

# List available instance types
aws ec2 describe-instance-types --region us-east-1

# Check limits
aws service-quotas list-service-quotas --service-code ec2
```

## 💡 Tips tiết kiệm chi phí

1. **Sử dụng Spot Instances** (AWS) - giảm 70% chi phí
2. **Chọn region rẻ** - US East thường rẻ nhất  
3. **Stop instance khi không dùng** - chỉ trả tiền storage
4. **Sử dụng Reserved Instances** cho long-term
5. **Set billing alerts** để tránh chi phí bất ngờ

## 🎉 Kết luận

Với cloud VPS, bạn có thể:
- ✅ Chạy AI/ML models nặng với GPU
- ✅ Có 16-112GB RAM cho big data
- ✅ 256GB SSD storage
- ✅ Cài đặt bất kỳ software nào
- ✅ Backup/restore dễ dàng

Chi phí chỉ từ $0.64-24/8 tiếng tùy cấu hình!

---

*Hướng dẫn này được cập nhật thường xuyên. Check phiên bản mới nhất trên repository.*
