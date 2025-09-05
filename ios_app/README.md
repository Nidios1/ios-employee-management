# Ứng dụng Quản lý Nhân viên iOS

Ứng dụng iOS được phát triển để kết nối với hệ thống quản lý nhân viên PHP hiện có.

## Tính năng chính

### 🔐 Xác thực
- Đăng nhập với TOTP (Time-based One-Time Password)
- Hỗ trợ nhiều hệ thống
- Bảo mật cao với mã OTP 6 số

### 📱 Giao diện người dùng
- **Trang chủ**: Tổng quan về thông tin cá nhân và chấm công
- **Chấm công**: Quản lý thời gian làm việc, lịch sử chấm công
- **Lương**: Xem thông tin lương và báo cáo tháng
- **Thông báo**: Nhận và quản lý thông báo từ hệ thống
- **Chat AI**: Tương tác với trợ lý AI thông minh
- **Hồ sơ**: Quản lý thông tin cá nhân và cài đặt

### 🚀 Tính năng nâng cao
- Pull-to-refresh cho tất cả danh sách
- Swipe actions cho thông báo
- Real-time TOTP countdown
- Upload ảnh đại diện
- Dark mode support
- Responsive design

## Yêu cầu hệ thống

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+
- Server PHP với API endpoints

## Cài đặt

### 1. Clone repository
```bash
git clone <repository-url>
cd ios_app
```

### 2. Mở dự án trong Xcode
```bash
open EmployeeManagementApp.xcodeproj
```

### 3. Cấu hình server
Cập nhật `Constants.baseURL` trong file `Models/Models.swift`:
```swift
static let baseURL = "https://your-server.com" // Thay đổi theo server của bạn
```

### 4. Cấu hình Bundle Identifier
1. Mở project trong Xcode
2. Chọn target "EmployeeManagementApp"
3. Vào tab "Signing & Capabilities"
4. Thay đổi Bundle Identifier thành tên duy nhất của bạn

### 5. Build và chạy
1. Chọn device hoặc simulator
2. Nhấn Cmd+R để build và chạy

## Cấu trúc dự án

```
EmployeeManagementApp/
├── ViewControllers/
│   ├── LoginViewController.swift      # Màn hình đăng nhập
│   ├── HomeViewController.swift       # Trang chủ
│   ├── AttendanceViewController.swift # Chấm công
│   ├── SalaryViewController.swift     # Lương
│   ├── NotificationsViewController.swift # Thông báo
│   ├── ChatViewController.swift       # Chat AI
│   └── ProfileViewController.swift    # Hồ sơ
├── Managers/
│   ├── NetworkManager.swift          # Quản lý API calls
│   ├── AuthManager.swift             # Quản lý xác thực
│   └── TOTPManager.swift             # Quản lý TOTP
├── Models/
│   └── Models.swift                  # Data models
├── Assets.xcassets                   # Hình ảnh và màu sắc
├── Main.storyboard                   # Storyboard chính
├── LaunchScreen.storyboard           # Màn hình khởi động
└── Info.plist                       # Cấu hình app
```

## API Endpoints

Ứng dụng kết nối với các API endpoints sau:

- `POST /login_process.php` - Đăng nhập
- `POST /clock_in_out.php` - Chấm công vào/ra
- `GET /attendance.php` - Lịch sử chấm công
- `GET /api_monthly_data.php` - Dữ liệu lương tháng
- `GET /api_notifications.php` - Thông báo
- `POST /api_chat.php` - Chat AI
- `GET /api_employee_detail.php` - Chi tiết nhân viên

## Bảo mật

- Tất cả API calls sử dụng HTTPS
- TOTP authentication bắt buộc
- Session management tự động
- Dữ liệu nhạy cảm được lưu trữ an toàn

## Tùy chỉnh

### Thay đổi màu sắc
Cập nhật trong `Assets.xcassets` hoặc sử dụng system colors.

### Thêm tính năng mới
1. Tạo ViewController mới
2. Thêm vào Main.storyboard
3. Cập nhật TabBarController
4. Implement logic trong NetworkManager

### Cấu hình TOTP
Sử dụng `TOTPManager.shared` để:
- Generate TOTP codes
- Validate TOTP codes
- Generate QR codes

## Troubleshooting

### Lỗi kết nối API
1. Kiểm tra `Constants.baseURL`
2. Đảm bảo server đang chạy
3. Kiểm tra network connectivity

### Lỗi TOTP
1. Kiểm tra thời gian thiết bị
2. Đảm bảo secret key đúng
3. Kiểm tra time window

### Lỗi build
1. Clean build folder (Cmd+Shift+K)
2. Reset simulator
3. Kiểm tra iOS deployment target

## Đóng góp

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## License

MIT License - xem file LICENSE để biết thêm chi tiết.

## Hỗ trợ

Nếu gặp vấn đề, vui lòng tạo issue trên GitHub hoặc liên hệ team phát triển.

---

**Lưu ý**: Đây là phiên bản demo. Để sử dụng trong production, cần thêm các tính năng bảo mật và tối ưu hóa khác.
