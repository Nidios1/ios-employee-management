# Employee Management iOS App

Ứng dụng iOS quản lý nhân viên kết nối với hệ thống PHP backend.

## Tính năng

### 🔐 **Xác thực**
- Đăng nhập với TOTP (Time-based One-Time Password)
- Quản lý session và token
- Đăng xuất an toàn

### ⏰ **Chấm công**
- Chấm công vào/ra
- Theo dõi thời gian làm việc
- Lịch sử chấm công

### 💰 **Quản lý lương**
- Xem lương theo tháng/năm
- Chi tiết lương cơ bản, phụ cấp, khấu trừ
- Tính toán lương thực lĩnh

### 🔔 **Thông báo**
- Nhận thông báo từ hệ thống
- Đánh dấu đã đọc
- Lịch sử thông báo

### 🤖 **Chat AI**
- Trò chuyện với AI assistant
- Hỗ trợ nhân viên 24/7
- Lưu lịch sử chat

### 👤 **Hồ sơ cá nhân**
- Xem thông tin cá nhân
- Cập nhật profile
- Quản lý tài khoản

## Kết nối API

App kết nối với các API endpoints:

- `POST /api/login_process.php` - Đăng nhập
- `POST /api/clock_in_out.php` - Chấm công
- `POST /api/api_monthly_data.php` - Lấy dữ liệu lương
- `POST /api/api_notifications.php` - Lấy thông báo
- `POST /api/api_chat.php` - Chat với AI

## Cấu trúc Project

```
ios_app/
├── EmployeeApp.xcodeproj/     # Xcode project
├── EmployeeApp/               # Source code
│   ├── EmployeeAppApp.swift   # App entry point
│   ├── ContentView.swift      # Main view controller
│   ├── LoginView.swift        # Login screen
│   ├── HomeView.swift         # Home screen với tabs
│   ├── Models.swift           # Data models
│   ├── NetworkManager.swift   # API manager
│   ├── AuthManager.swift      # Authentication manager
│   └── Info.plist            # App configuration
├── .github/workflows/
│   └── build.yml             # GitHub Actions workflow
└── README.md                 # Documentation
```

## Build và Deploy

### **GitHub Actions**
- Tự động build khi push code
- Tạo IPA file
- Upload vào Artifacts

### **Download IPA**
1. Vào **Actions** tab trong GitHub
2. Chọn workflow run mới nhất
3. Download **EmployeeApp.ipa** từ Artifacts

### **Cài đặt**
- Cần Apple Developer account để cài trên thiết bị thật
- Sử dụng TestFlight để chia sẻ app
- Hoặc cài qua Xcode với developer certificate

## Yêu cầu hệ thống

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.0+**
- **Kết nối internet** để gọi API

## Cấu hình

### **Base URL**
Sửa `Constants.baseURL` trong `Models.swift`:
```swift
static let baseURL = "http://your-server.com/employee_management"
```

### **API Endpoints**
Các endpoint API phải trả về JSON format:
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

## Lưu ý

- App sử dụng **NSAllowsArbitraryLoads** để kết nối HTTP
- Tất cả API calls đều bất đồng bộ (async)
- Dữ liệu được cache trong UserDefaults
- Hỗ trợ cả iPhone và iPad
