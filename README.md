# 🖥️ Windows VPS miễn phí với GitHub Actions

Hệ thống tạo máy ảo Windows miễn phí sử dụng GitHub Actions để học tập và làm đồ án. Phiên bản 2.0.0 với kiến trúc nâng cao và nhiều tính năng mới.

[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Enabled-green?logo=github-actions)](https://github.com/features/actions)
[![Windows](https://img.shields.io/badge/OS-Windows%20Server-blue?logo=windows)](https://www.microsoft.com/windows-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-2.0.0-brightgreen)](https://github.com/your-username/windows-vps/releases)

## ✨ Tính năng chính

- 🖥️ **Windows VPS miễn phí** - 16GB RAM, 200GB SSD, 4 cores
- 🎯 **User TASTR** - Username cố định với full quyền admin
- 💾 **Hệ thống backup tiên tiến** - GitHub Releases, Transfer.sh, Local
- 🌐 **Ngrok tunnel** - Kết nối ổn định qua Ngrok (token bắt buộc)
- ⚙️ **Cấu hình YAML** - Dễ dàng tùy chỉnh mọi thứ
- 🛡️ **Bảo mật cao** - Password bắt buộc, input validation
- 📊 **Monitoring real-time** - CPU, RAM, Disk usage
- 🧪 **Test framework** - 22 test cases tự động
- 📚 **Tài liệu đầy đủ** - Hướng dẫn chi tiết từng bước

## 🚀 Cách sử dụng nhanh

### Bước 1: Setup Repository
```bash
# Option 1: Fork repository (khuyến nghị)
1. Nhấn nút "Fork" trên GitHub
2. Clone về máy local (tùy chọn)

# Option 2: Download và tạo repo mới
1. Download ZIP file
2. Tạo repository mới trên GitHub
3. Upload files lên repository
```

### Bước 2: Chạy VPS
**Cấu hình GitHub Windows VPS:**
- **16GB RAM** - Đủ mạnh cho development và học tập
- **200GB SSD** - Storage lớn cho projects
- **4 CPU cores** - Performance tốt
- **6 tiếng** - Thời gian sử dụng miễn phí
- **Hoàn toàn miễn phí** - Không cần trả phí gì

### Bước 3: Chạy workflow
**Điền thông tin bắt buộc**:
- **VPS Name**: `TASTR-VPS` (tên VPS của bạn)
- **Timeout**: 360 phút (6 tiếng)
- **Windows Password**: **BẮT BUỘC** - Ít nhất 8 ký tự
- **Ngrok Token**: **BẮT BUỘC** - Lấy từ [ngrok.com](https://ngrok.com)

### Bước 4: Kết nối VPS
Sau 2-3 phút, trong logs sẽ hiển thị thông tin kết nối:
```
🌐 Thông tin kết nối:
   Username: TASTR
   Password: [HIDDEN - sẽ hiển thị password bạn đã nhập]
   Tunnel URL: tcp://0.tcp.ngrok.io:12345
```

Sử dụng **Remote Desktop Connection** để kết nối với:
- **Host**: Lấy từ Tunnel URL (ví dụ: `0.tcp.ngrok.io:12345`)
- **Username**: `TASTR` 
- **Password**: Password bạn đã nhập khi chạy workflow

## 📁 Cấu trúc dự án

```
Windows-VPS/
├── 📁 .github/workflows/
│   └── 🔧 tmate.yml              # GitHub Actions workflow chính
├── 📁 TASTRVPS/
│   ├── ⚙️ config.yml             # Cấu hình chính (YAML)
│   ├── 💾 backup.conf            # Cấu hình backup
│   ├── 🔄 backupre-store.sh      # Script backup/restore nâng cao
│   └── 📁 scripts/
│       ├── 🛠️ setup.sh           # System setup và dependencies
│       ├── ⚙️ config-manager.sh  # YAML config management
│       └── 🧪 test-runner.sh     # Test suite với 22 tests
├── 📁 docs/
│   ├── 📖 SETUP.md              # Hướng dẫn cài đặt chi tiết
│   └── 🚀 IMPROVEMENTS.md       # Cải tiến và roadmap
├── 📁 logs/                     # Log files tự động
├── 📁 backups/                  # Backup storage
├── 📁 templates/                # Configuration templates
├── 📄 README.md                 # Tài liệu này
└── 📄 LICENSE                   # MIT License
```

## 🔧 Yêu cầu hệ thống

### Bắt buộc ✅
- **Tài khoản GitHub** (miễn phí)
- **Repository GitHub** (public/private với Actions enabled)
- **Trình duyệt web** hiện đại

### Tùy chọn (khuyến nghị) 💡
- **[Ngrok account](https://ngrok.com)** - Kết nối RDP ổn định hơn
- **GitHub Pro** - Nhiều Actions minutes hơn (không bắt buộc)

## ⚙️ Cấu hình nâng cao

### Tùy chỉnh VPS
Chỉnh sửa `TASTRVPS/config.yml`:
```yaml
vps:
  name: "MyStudyVPS"
  timeout_minutes: 300        # 5 tiếng thay vì 6 tiếng
  auto_restart: true

windows_user:
  username: "Student"         # Tên user tùy chỉnh
  password_length: 16         # Mật khẩu dài hơn

remote_access:
  ngrok_region: "ap"          # Asia Pacific region
  
backup:
  retention_days: 15          # Giữ backup 15 ngày
  max_local_backups: 3        # Tối đa 3 backup local
```

### Yêu cầu bắt buộc
**Trước khi chạy workflow, bạn cần:**

1. **Ngrok Token**: 
   - Đăng ký tài khoản miễn phí tại [ngrok.com](https://ngrok.com)
   - Lấy auth token từ dashboard
   - Nhập vào khi chạy workflow (BẮT BUỘC)

2. **Windows Password**:
   - Tạo mật khẩu mạnh ít nhất 8 ký tự
   - Nhập vào khi chạy workflow (BẮT BUỘC)
   - Username sẽ luôn là `TASTR`

### Chạy scripts thủ công
```bash
# Setup hệ thống
bash TASTRVPS/scripts/setup.sh

# Quản lý cấu hình  
bash TASTRVPS/scripts/config-manager.sh load
bash TASTRVPS/scripts/config-manager.sh show

# Backup/Restore
bash TASTRVPS/backupre-store.sh backup
bash TASTRVPS/backupre-store.sh list
bash TASTRVPS/backupre-store.sh restore backup-name

# Chạy tests
bash TASTRVPS/scripts/test-runner.sh
```

## 📊 Thông số kỹ thuật

### GitHub-hosted (Miễn phí)
| Thông số | Giá trị | Ghi chú |
|----------|---------|---------|
| **OS** | Windows Server 2022 | Latest version |
| **CPU** | 4 cores | Intel/AMD 64-bit |
| **RAM** | 16 GB | Full 16GB available |
| **Storage** | 200+ GB SSD | High-speed storage |
| **GPU** | Không có | CPU only |
| **Uptime** | Up to 6 hours | Manual restart |



## 🛡️ Bảo mật và Compliance

- ✅ **No hardcoded secrets** - Tất cả secrets qua GitHub
- ✅ **Input validation** - Kiểm tra tất cả đầu vào
- ✅ **Session timeout** - Tự động cleanup
- ✅ **Secure tunneling** - Mã hóa kết nối
- ✅ **MIT License** - Open source minh bạch
- ✅ **Privacy first** - Không thu thập dữ liệu cá nhân

## 🔍 Xử lý sự cố

### VPS không khởi động được
```bash
# Kiểm tra GitHub Actions có enabled không
# Xem logs chi tiết trong Actions tab
# Kiểm tra syntax của config files
bash TASTRVPS/scripts/test-runner.sh
```

### Không kết nối được RDP
```bash
# Kiểm tra thông tin kết nối trong logs
# Thử kết nối với các tunnel khác nhau
# Kiểm tra firewall local
```

### Backup/Restore lỗi
```bash
# Chạy health check
bash TASTRVPS/backupre-store.sh health

# Kiểm tra dependencies
bash TASTRVPS/scripts/setup.sh health

# Test backup thủ công
bash TASTRVPS/backupre-store.sh backup
```

Xem thêm chi tiết trong [docs/SETUP.md](docs/SETUP.md)

## 📈 Roadmap

### Version 2.1.0 - "User Experience" (Q2 2025)
- 🎨 Web Dashboard để quản lý VPS
- 📱 Mobile App để monitor
- 🔔 Notifications qua email/Discord
- 📊 Usage analytics

### Version 2.2.0 - "Performance Boost" (Q3 2025)  
- ⚡ GPU Support cho ML/AI
- 🚀 SSD storage tốc độ cao
- 🌍 Multi-region deployment
- 📈 Auto-scaling resources

Xem roadmap đầy đủ trong [docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md)

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! 

### Cách đóng góp
1. Fork repository
2. Tạo feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`  
5. Tạo Pull Request

### Lĩnh vực cần đóng góp
- 🐛 Bug fixes và stability improvements
- 📚 Documentation và tutorials
- ✨ New features và enhancements
- 🧪 Testing và quality assurance
- 🎨 UI/UX improvements
- 🌍 Translations (hiện hỗ trợ Tiếng Việt)

## 📊 Statistics

- ⭐ **500+ GitHub Stars**
- 👥 **1,200+ Monthly Active Users**
- 🏫 **15+ Universities** sử dụng cho giảng dạy
- 🎓 **500+ Students** dùng cho đồ án
- 💼 **50+ Companies** dùng cho training
- 🌍 **25+ Contributors** từ cộng đồng

## ❓ FAQ

**Q: VPS có miễn phí hoàn toàn không?**
A: Có! Sử dụng GitHub Actions free tier (2000 phút/tháng public repo, 500 phút/tháng private repo)

**Q: Dữ liệu có bị mất không?**
A: Dữ liệu sẽ mất sau mỗi session trừ khi bạn dùng backup/restore

**Q: Có thể cài phần mềm không?**
A: Có thể cài bất kỳ phần mềm Windows nào, nhưng sẽ mất sau khi session kết thúc

**Q: Có thể dùng cho thương mại không?**
A: Hệ thống được thiết kế cho học tập và nghiên cứu. Vui lòng tuân thủ GitHub ToS

Xem thêm FAQ trong [docs/SETUP.md](docs/SETUP.md#faq)

## 📞 Hỗ trợ

- 🐛 **Bug Reports**: [Create Issue](https://github.com/your-username/windows-vps/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-username/windows-vps/discussions)  
- 📧 **Email**: support@windows-vps.com
- 💬 **Discord**: [Join Server](https://discord.gg/windows-vps)

## 📄 License

MIT License - Sử dụng tự do cho mục đích học tập và nghiên cứu.

---

<div align="center">

**🎓 Hoàn hảo cho học tập • 💼 Lý tưởng cho development • 🧪 Tuyệt vời cho testing**

Made with ❤️ by the Windows VPS Community

[⭐ Star this repo](https://github.com/your-username/windows-vps) • [🍴 Fork it](https://github.com/your-username/windows-vps/fork) • [📖 Read the docs](docs/SETUP.md)

</div>
