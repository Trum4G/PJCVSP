# 🚀 Hướng dẫn tạo Repository và Push lên GitHub

## 📋 Bước 1: Tạo Repository trên GitHub

### 1. Đăng nhập GitHub
- Vào [github.com](https://github.com)
- Đăng nhập vào tài khoản của bạn

### 2. Tạo Repository mới
- Click nút **"New"** hoặc **"+"** ở góc trên bên phải
- Chọn **"New repository"**

### 3. Điền thông tin Repository
```
Repository name: windows-vm-learning
Description: Windows VM for Learning and Projects with Ngrok support
Visibility: Public (quan trọng để có 6 giờ runtime miễn phí)
```

**Lưu ý quan trọng:**
- ✅ Chọn **Public** để có 6 giờ runtime miễn phí
- ❌ Không check "Add a README file" (vì chúng ta đã có)
- ❌ Không check "Add .gitignore" (vì chúng ta đã có)

### 4. Tạo Repository
- Click **"Create repository"**

## 📋 Bước 2: Push Code lên GitHub

### Cách 1: Sử dụng Script tự động
```bash
# Chạy script tự động
./push-to-github.bat
```

### Cách 2: Thủ công
```bash
# Thêm remote origin (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/windows-vm-learning.git

# Push code lên GitHub
git push -u origin main
```

## 📋 Bước 3: Kiểm tra Repository

### 1. Truy cập Repository
- Vào URL: `https://github.com/YOUR_USERNAME/windows-vm-learning`

### 2. Kiểm tra Files
Đảm bảo các file sau đã được upload:
- ✅ `.github/workflows/windows-vm.yml`
- ✅ `README.md`
- ✅ `.gitignore`

### 3. Kiểm tra Actions
- Vào tab **Actions**
- Bạn sẽ thấy workflow **"Windows VM for Learning and Projects"**

## 🎯 Bước 4: Sử dụng Workflow

### 1. Chạy Workflow
- Vào tab **Actions**
- Chọn workflow **"Windows VM for Learning and Projects"**
- Click **"Run workflow"**

### 2. Cấu hình Workflow
```
VM Type: windows-latest
Setup Tools: ✅
Setup Database: ✅
Run Time Minutes: 360 (hoặc thời gian mong muốn)
Ngrok Authtoken: (tùy chọn)
```

### 3. Chờ Workflow hoàn thành
- Workflow sẽ mất khoảng 10-15 phút để cài đặt
- Kiểm tra logs để xem tiến trình

## 🔧 Troubleshooting

### Lỗi "Repository not found"
- Kiểm tra URL repository có đúng không
- Đảm bảo repository đã được tạo trên GitHub

### Lỗi Authentication
- Đảm bảo đã đăng nhập GitHub
- Có thể cần tạo Personal Access Token

### Lỗi Push
```bash
# Nếu có lỗi, thử:
git pull origin main --allow-unrelated-histories
git push origin main
```

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs trong GitHub Actions
2. Tạo Issue trong repository
3. Đảm bảo repository là Public

---

**Happy Coding! 🎉**
