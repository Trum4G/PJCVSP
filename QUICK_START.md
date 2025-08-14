# 🚀 TASTR Windows VPS - Hướng dẫn nhanh

## 📋 Yêu cầu bắt buộc

### 1. Ngrok Token (BẮT BUỘC)
1. Truy cập [ngrok.com](https://ngrok.com)
2. Đăng ký tài khoản miễn phí
3. Vào Dashboard → Your Authtoken
4. Copy token (dạng: `2abc...xyz`)

### 2. Windows Password (BẮT BUỘC)
- Tạo mật khẩu mạnh ít nhất 8 ký tự
- Ví dụ: `MySecure123!`
- Username sẽ luôn là **TASTR**

## 🖥️ Thông số VPS

| Thông số | Giá trị |
|----------|---------|
| **RAM** | 16 GB |
| **Storage** | 200+ GB SSD |
| **GPU** | Không có |
| **CPU** | 4 cores |
| **Username** | TASTR |
| **Thời gian** | Tối đa 6 tiếng |

## ⚡ Cách chạy VPS

### Bước 1: Fork Repository
1. Nhấn nút **"Fork"** trên GitHub
2. Chờ fork hoàn tất

### Bước 2: Chạy Workflow
1. Vào repository đã fork
2. Nhấn tab **"Actions"**
3. Chọn **"Create Windows VPS"**
4. Nhấn **"Run workflow"**
5. Điền thông tin:
   ```
   VPS Name: TASTR-VPS
   Backup: false
   Timeout: 360
   Windows Password: [MẬT KHẨU CỦA BẠN]
   Ngrok Token: [TOKEN TỪ NGROK.COM]
   ```
6. Nhấn **"Run workflow"**

### Bước 3: Đợi VPS khởi động
- Thời gian: 2-3 phút
- Theo dõi trong Actions logs
- Chờ thông báo "VPS đã sẵn sàng sử dụng!"

### Bước 4: Kết nối RDP
1. Tìm thông tin kết nối trong logs:
   ```
   Username: TASTR
   Password: [HIDDEN]
   Tunnel URL: tcp://0.tcp.ngrok.io:12345
   ```

2. Mở **Remote Desktop Connection**:
   - **Computer**: `0.tcp.ngrok.io:12345` (từ Tunnel URL)
   - **Username**: `TASTR`
   - **Password**: Mật khẩu bạn đã nhập

3. Nhấn **Connect** và sử dụng!

## 🎯 Lưu ý quan trọng

### ✅ Có thể làm
- Cài đặt bất kỳ phần mềm nào
- Lập trình, học tập, làm đồ án
- Chạy ứng dụng nặng (16GB RAM)
- Development tools, IDE, databases
- Sử dụng 16GB RAM và 200GB storage

### ❌ Không thể
- Dữ liệu sẽ mất sau 6 tiếng
- Không có IP tĩnh
- Không tự động khởi động lại
- Không thể thay đổi username (luôn là TASTR)

### 💡 Tips
- Backup dữ liệu quan trọng lên GitHub/Google Drive
- Sử dụng ngrok token của riêng bạn để tránh giới hạn
- Chạy lại workflow để tạo VPS mới khi cần

## 🆘 Xử lý sự cố

### VPS không khởi động
- Kiểm tra GitHub Actions có enabled không
- Xem logs chi tiết trong Actions tab
- Đảm bảo ngrok token và password hợp lệ

### Không kết nối được RDP
- Kiểm tra Tunnel URL có đúng format không
- Thử restart ngrok tunnel
- Kiểm tra firewall local

### Token ngrok không hoạt động
- Đăng nhập lại ngrok.com
- Tạo token mới
- Đảm bảo copy đúng token

## 📞 Hỗ trợ

- **GitHub Issues**: [Tạo issue mới](https://github.com/your-username/windows-vps/issues)
- **Documentation**: [README.md](README.md)
- **Setup Guide**: [docs/SETUP.md](docs/SETUP.md)

---

**🎓 Chúc bạn học tập và phát triển thành công với TASTR Windows VPS!**
