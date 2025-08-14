# 🖥️ Windows VM cho Học tập và Đồ án

Repository này chứa GitHub Actions workflow để tạo máy ảo Windows cho việc học tập và làm đồ án trường học với khả năng tùy chỉnh thời gian chạy và kết nối từ xa qua Ngrok.

## 🚀 Cách sử dụng

### Chạy Workflow

1. Vào tab **Actions** trong repository này
2. Chọn workflow **"Windows VM for Learning and Projects"**
3. Click **"Run workflow"**
4. Chọn các tùy chọn:
   - **VM Type**: `windows-latest` (khuyến nghị)
   - **Setup Tools**: ✅ (cài đặt công cụ phát triển)
   - **Setup Database**: ✅ (cài đặt database local)
   - **Run Time Minutes**: Nhập thời gian chạy (1-360 phút)
   - **Ngrok Authtoken**: Nhập authtoken để kết nối từ xa (tùy chọn)
5. Click **"Run workflow"**

## 🛠️ Công cụ được cài đặt

### Ngôn ngữ lập trình
- **Node.js** (v18) - JavaScript runtime
- **Python** (v3.11) - Ngôn ngữ lập trình đa năng
- **Java** (OpenJDK 11) - Lập trình hướng đối tượng
- **.NET** - Framework của Microsoft
- **Go** - Ngôn ngữ của Google
- **Rust** - Ngôn ngữ hệ thống

### Framework và thư viện
- **Web Development**: Express.js, Angular, Vue.js, React
- **Python**: Django, Flask, FastAPI, Jupyter Notebook
- **Data Science**: Pandas, NumPy, Matplotlib

### Công cụ phát triển
- **VS Code** - Editor chính
- **Git** - Quản lý version
- **Postman** - Test API
- **Docker Desktop** - Containerization
- **Notepad++** - Text editor
- **Ngrok** - Kết nối từ xa (nếu có authtoken)

### Cơ sở dữ liệu (Local)
- **MySQL** - Database quan hệ
- **PostgreSQL** - Database nâng cao
- **SQLite** - Database nhẹ

## 📁 Cấu trúc thư mục

```
C:\Projects\
├── Learning\          # Cho việc học tập
├── School\            # Cho đồ án trường
├── Personal\          # Cho dự án cá nhân
└── start-ngrok.bat    # Script khởi động Ngrok (nếu có)
```

## 🌐 Kết nối từ xa với Ngrok

Nếu bạn cung cấp Ngrok authtoken, máy ảo sẽ tự động:

1. **Cài đặt và cấu hình Ngrok**
2. **Tạo các tunnels**:
   - SSH (port 22)
   - RDP (port 3389)
   - Web (port 3000)
   - API (port 8000)
3. **Hiển thị URL kết nối** trong logs

### Cách lấy Ngrok Authtoken:
1. Đăng ký tại [ngrok.com](https://ngrok.com)
2. Vào Dashboard → Your Authtoken
3. Copy authtoken và paste vào workflow

### Kết nối từ xa:
- **SSH**: Sử dụng URL SSH từ logs
- **RDP**: Kết nối Remote Desktop với URL RDP
- **Web**: Truy cập ứng dụng web qua URL Web
- **API**: Test API qua URL API

## 💡 Lưu ý quan trọng

### ⚠️ Giới hạn GitHub Actions
- **Thời gian chạy**: Tùy chỉnh từ 1-360 phút
- **Lưu trữ**: Máy ảo sẽ bị xóa sau khi hết thời gian
- **Dữ liệu**: Commit và push code thường xuyên để không mất dữ liệu

### 🔄 Quản lý dữ liệu
1. **Lưu code**: Commit và push thường xuyên
2. **Backup**: Sử dụng GitHub để lưu trữ
3. **Database**: Export dữ liệu trước khi kết thúc workflow

### 🌐 Ngrok Lưu ý
- Authtoken là tùy chọn, không bắt buộc
- Miễn phí có giới hạn 1 tunnel đồng thời
- Pro plan cho nhiều tunnels và tính năng nâng cao

## 🎯 Các trường hợp sử dụng

### Cho học tập
- Thực hành lập trình
- Học framework mới
- Thử nghiệm công nghệ
- Làm bài tập

### Cho đồ án trường
- Phát triển ứng dụng web
- Xây dựng API
- Làm việc với database
- Testing và debugging
- Demo từ xa cho giáo viên

### Cho dự án cá nhân
- Prototype ý tưởng
- Học công nghệ mới
- Portfolio projects
- Chia sẻ demo với người khác

## 🚀 Bắt đầu nhanh

### 1. Clone repository
```bash
git clone https://github.com/your-username/windows-vm-learning.git
cd windows-vm-learning
```

### 2. Chạy workflow
- Vào GitHub → Actions → Chọn workflow → Run workflow
- Điền thông tin cần thiết
- Chờ máy ảo khởi tạo

### 3. Sử dụng máy ảo
- Workflow sẽ tự động cài đặt tất cả công cụ
- Sử dụng VS Code để code
- Database đã sẵn sàng để sử dụng
- Ngrok tunnels đã được khởi động (nếu có authtoken)

## 📚 Tài liệu tham khảo

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Windows Runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)
- [Chocolatey Package Manager](https://chocolatey.org/)
- [VS Code](https://code.visualstudio.com/)
- [Ngrok Documentation](https://ngrok.com/docs)

## 🤝 Đóng góp

Nếu bạn muốn cải thiện workflow này:

1. Fork repository
2. Tạo branch mới: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push branch: `git push origin feature/new-feature`
5. Tạo Pull Request

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs trong GitHub Actions
2. Tạo Issue với thông tin chi tiết
3. Đảm bảo repository là public (để có 6 giờ runtime)
4. Kiểm tra Ngrok authtoken nếu sử dụng kết nối từ xa

---

**Happy Coding! 🎉**
