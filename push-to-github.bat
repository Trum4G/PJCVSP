@echo off
echo ========================================
echo    Windows VM Learning Repository
echo ========================================
echo.
echo Hướng dẫn tạo repository trên GitHub:
echo 1. Vào github.com và đăng nhập
echo 2. Click "New" -> "New repository"
echo 3. Đặt tên: windows-vm-learning
echo 4. Chọn Public
echo 5. Click "Create repository"
echo.
echo Sau đó copy URL repository và paste vào đây:
echo (Ví dụ: https://github.com/username/windows-vm-learning.git)
echo.
set /p repo_url="Nhập URL repository: "

if "%repo_url%"=="" (
    echo Không có URL được nhập. Thoát...
    pause
    exit /b 1
)

echo.
echo Đang thêm remote origin...
git remote add origin %repo_url%

echo.
echo Đang push code lên GitHub...
git push -u origin main

echo.
echo Hoàn thành! Repository đã được push lên GitHub.
echo Bạn có thể truy cập: %repo_url%
echo.
pause
