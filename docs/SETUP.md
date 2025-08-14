# 🖥️ Hướng dẫn cài đặt Windows VPS

Tài liệu này hướng dẫn chi tiết cách cài đặt và sử dụng hệ thống Windows VPS miễn phí với GitHub Actions.

## 📋 Mục lục

1. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
2. [Cài đặt nhanh](#cài-đặt-nhanh)
3. [Cài đặt chi tiết](#cài-đặt-chi-tiết)
4. [Cấu hình nâng cao](#cấu-hình-nâng-cao)
5. [Xử lý sự cố](#xử-lý-sự-cố)
6. [FAQ](#faq)

## 🔧 Yêu cầu hệ thống

### Bắt buộc
- **Tài khoản GitHub** (miễn phí)
- **Repository GitHub** (public hoặc private với GitHub Actions enabled)
- **Trình duyệt web** hiện đại (Chrome, Firefox, Edge, Safari)

### Tùy chọn (để có trải nghiệm tốt hơn)
- **Ngrok account** - Để có kết nối RDP ổn định hơn
- **GitHub Pro** - Để có thời gian chạy Actions dài hơn (không bắt buộc)

## ⚡ Cài đặt nhanh

### Bước 1: Fork Repository
1. Truy cập repository này trên GitHub
2. Nhấn nút **"Fork"** ở góc trên bên phải
3. Chọn tài khoản của bạn để fork

### Bước 2: Kích hoạt GitHub Actions
1. Vào repository đã fork của bạn
2. Nhấn tab **"Actions"**
3. Nếu được hỏi, nhấn **"I understand my workflows, enable them"**

### Bước 3: Chạy VPS
1. Trong tab **Actions**, chọn workflow **"Create Windows VPS (Auto Restart)"**
2. Nhấn **"Run workflow"**
3. Điền thông tin (hoặc để mặc định):
   - **VPS Name**: Tên VPS của bạn (ví dụ: StudyVPS)
   - **Backup**: Có khôi phục từ backup không
   - **Timeout**: Thời gian chạy (tối đa 360 phút = 6 tiếng)
   - **Windows Password**: Mật khẩu tùy chỉnh (để trống để tự động tạo)
   - **Ngrok Token**: Token ngrok (tùy chọn)
4. Nhấn **"Run workflow"**

### Bước 4: Đợi VPS khởi động
- Quá trình khởi động mất khoảng 2-3 phút
- Theo dõi tiến trình trong tab **Actions**
- Khi thấy thông báo **"VPS đã sẵn sàng sử dụng!"**, VPS đã hoạt động

### Bước 5: Kết nối VPS
1. Trong logs của workflow, tìm thông tin kết nối:
   ```
   Username: Administrator
   Password: ABC123XYZ789
   Tunnel URL: tcp://0.tcp.ngrok.io:12345
   ```
2. Sử dụng **Remote Desktop Connection** (Windows) hoặc **Microsoft Remote Desktop** (Mac/Linux)
3. Nhập thông tin kết nối và bắt đầu sử dụng!

## 🔧 Cài đặt chi tiết

### Chuẩn bị Repository

#### Option 1: Fork Repository (Khuyến nghị)
```bash
# 1. Fork repository trên GitHub
# 2. Clone về máy local (tùy chọn)
git clone https://github.com/YOUR_USERNAME/windows-vps.git
cd windows-vps
```

#### Option 2: Tạo Repository mới
```bash
# Tạo repository mới và copy files
mkdir my-windows-vps
cd my-windows-vps
git init

# Copy tất cả files từ repository này
# Sau đó push lên GitHub repository mới của bạn
```

### Cấu hình GitHub Secrets (Tùy chọn)

Để có trải nghiệm tốt hơn, bạn có thể thêm các secrets:

1. Vào **Settings** > **Secrets and variables** > **Actions**
2. Thêm các secrets sau:

#### NGROK_TOKEN (Khuyến nghị)
- Đăng ký tài khoản miễn phí tại [ngrok.com](https://ngrok.com)
- Lấy auth token từ dashboard
- Thêm secret với tên `NGROK_TOKEN`

#### CUSTOM_PASSWORD (Tùy chọn)
- Đặt mật khẩu Windows cố định
- Mật khẩu phải có ít nhất 8 ký tự
- Thêm secret với tên `CUSTOM_PASSWORD`

### Chạy VPS lần đầu

1. **Vào Actions tab**
2. **Chọn workflow "Create Windows VPS (Auto Restart)"**
3. **Nhấn "Run workflow"**
4. **Cấu hình parameters:**

   | Parameter | Mô tả | Mặc định | Gợi ý |
   |-----------|--------|----------|--------|
   | VPS Name | Tên VPS | StudyVPS | Tên dự án của bạn |
   | Backup | Khôi phục backup | false | true nếu đã có backup |
   | Timeout | Thời gian chạy (phút) | 360 | 360 (6 tiếng) |
   | Windows Password | Mật khẩu tùy chỉnh | (trống) | Để trống cho tự động |
   | Ngrok Token | Token ngrok | (trống) | Điền nếu có |

5. **Nhấn "Run workflow"**

### Theo dõi quá trình khởi động

VPS sẽ trải qua các bước sau:
1. **Validate Inputs** - Kiểm tra đầu vào
2. **Prepare Directories** - Chuẩn bị thư mục
3. **Load Configuration** - Tải cấu hình
4. **Setup Windows RDP** - Cài đặt Remote Desktop
5. **Setup Remote Access Tunnel** - Tạo tunnel kết nối
6. **Keep-alive Monitoring** - Giám sát và duy trì kết nối

## ⚙️ Cấu hình nâng cao

### Tùy chỉnh config.yml

Sửa file `TASTRVPS/config.yml` để tùy chỉnh:

```yaml
# VPS Settings
vps:
  name: "MyStudyVPS"
  timeout_minutes: 300  # 5 tiếng thay vì 6 tiếng
  auto_restart: true

# Windows User
windows_user:
  username: "Student"    # Tên user tùy chỉnh
  password_length: 16    # Mật khẩu dài hơn

# Remote Access
remote_access:
  ngrok_region: "ap"     # Asia Pacific region
  
# Backup
backup:
  retention_days: 15     # Giữ backup 15 ngày
  max_local_backups: 3   # Tối đa 3 backup local
```

### Tùy chỉnh backup.conf

Sửa file `TASTRVPS/backup.conf`:

```bash
# Backup settings
COMPRESSION_LEVEL=9          # Nén tối đa
RETENTION_DAYS=15           # Giữ 15 ngày
MAX_LOCAL_BACKUPS=3         # Tối đa 3 backup

# Backup methods
PRIMARY_METHOD="github_releases"
FALLBACK_METHOD="transfer_sh"
```

### Chạy Scripts thủ công

Bạn có thể chạy các scripts thủ công để test:

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

## 🔧 Xử lý sự cố

### VPS không khởi động được

**Triệu chứng:** Workflow bị lỗi ở bước đầu

**Giải pháp:**
1. Kiểm tra GitHub Actions có được enable không
2. Kiểm tra repository có quyền chạy Actions không
3. Xem logs chi tiết để tìm lỗi cụ thể

### Không thể kết nối RDP

**Triệu chứng:** Không kết nối được Remote Desktop

**Giải pháp:**
1. **Kiểm tra thông tin kết nối:**
   - Username và password có đúng không
   - URL tunnel có đúng format không
   
2. **Thử các cách kết nối khác:**
   - Nếu có Ngrok URL: `tcp://0.tcp.ngrok.io:12345`
   - Nếu có Playit: Kiểm tra logs để lấy thông tin
   - Nếu có tmate: Dùng SSH tunnel

3. **Kiểm tra firewall:**
   - Tắt Windows Firewall tạm thời
   - Kiểm tra firewall của router/ISP

### VPS bị disconnect

**Triệu chứng:** Mất kết nối giữa chừng

**Giải pháp:**
1. **Kiểm tra thời gian:**
   - VPS chỉ chạy tối đa 6 tiếng
   - Sẽ tự động restart sau khi hết thời gian

2. **Kiểm tra tunnel:**
   - Ngrok free có giới hạn thời gian
   - Playit có thể bị ngắt kết nối

3. **Backup trước khi mất kết nối:**
   - Sử dụng tính năng auto-backup
   - Backup thủ công quan trọng files

### Backup/Restore không hoạt động

**Triệu chứng:** Lỗi khi backup hoặc restore

**Giải pháp:**
1. **Kiểm tra dependencies:**
   ```bash
   bash TASTRVPS/backupre-store.sh health
   ```

2. **Kiểm tra permissions:**
   - GitHub token có quyền tạo releases không
   - Repository có quyền write không

3. **Thử backup method khác:**
   - GitHub Releases (cần token)
   - Transfer.sh (không cần setup)
   - Local storage (luôn hoạt động)

### Lỗi cấu hình

**Triệu chứng:** Workflow báo lỗi validation

**Giải pháp:**
1. **Kiểm tra YAML syntax:**
   ```bash
   bash TASTRVPS/scripts/config-manager.sh validate
   ```

2. **Kiểm tra giá trị cấu hình:**
   - Timeout: 30-360 phút
   - Password length: 8-128 ký tự
   - VPS name: chỉ chữ, số, gạch ngang, gạch dưới

3. **Reset về cấu hình mặc định:**
   ```bash
   bash TASTRVPS/scripts/config-manager.sh create
   ```

## ❓ FAQ

### Q: VPS có miễn phí hoàn toàn không?
**A:** Có, hoàn toàn miễn phí. Sử dụng GitHub Actions free tier (2000 phút/tháng cho public repo, 500 phút/tháng cho private repo).

### Q: VPS có thể chạy bao lâu?
**A:** Tối đa 6 tiếng mỗi session. Sau đó sẽ tự động restart và tạo session mới.

### Q: Dữ liệu có bị mất không?
**A:** Dữ liệu sẽ mất sau mỗi session trừ khi bạn sử dụng tính năng backup/restore.

### Q: Có thể cài đặt phần mềm không?
**A:** Có, bạn có thể cài đặt bất kỳ phần mềm nào trên Windows. Nhưng sẽ mất sau khi session kết thúc.

### Q: Có thể sử dụng cho mục đích thương mại không?
**A:** Hệ thống này được thiết kế cho mục đích học tập và nghiên cứu. Vui lòng tuân thủ Terms of Service của GitHub.

### Q: VPS có IP tĩnh không?
**A:** Không, IP sẽ thay đổi sau mỗi session restart.

### Q: Có thể kết nối nhiều người cùng lúc không?
**A:** Có, Windows hỗ trợ multiple RDP sessions, nhưng hiệu suất sẽ giảm.

### Q: Làm sao để backup code/dữ liệu?
**A:** Sử dụng tính năng backup tích hợp hoặc push code lên GitHub repository.

### Q: VPS có internet không?
**A:** Có, kết nối internet tốc độ cao thông qua datacenter của GitHub.

### Q: Có thể chạy game không?
**A:** Có thể chạy game nhẹ, nhưng không khuyến nghị vì không có GPU và có giới hạn thời gian.

## 📞 Hỗ trợ

Nếu gặp vấn đề, bạn có thể:

1. **Kiểm tra logs:** Xem chi tiết trong Actions logs
2. **Chạy health check:** `bash TASTRVPS/scripts/test-runner.sh`
3. **Tạo issue:** Trên GitHub repository
4. **Tham khảo docs:** Xem thêm tài liệu trong thư mục `docs/`

## 🎯 Mẹo sử dụng hiệu quả

1. **Backup thường xuyên:** Backup trước khi làm thay đổi lớn
2. **Sử dụng Git:** Push code quan trọng lên GitHub
3. **Chuẩn bị trước:** Download phần mềm cần thiết trước khi session hết hạn
4. **Tối ưu thời gian:** Sử dụng script automation cho các tác vụ lặp lại
5. **Monitor usage:** Theo dõi GitHub Actions minutes để không bị quá hạn mức

---

*Tài liệu này được cập nhật thường xuyên. Vui lòng check phiên bản mới nhất trên repository.*
