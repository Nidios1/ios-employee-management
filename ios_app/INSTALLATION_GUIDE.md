# Hướng dẫn cài đặt ứng dụng iOS

## Bước 1: Chuẩn bị môi trường phát triển

### Yêu cầu hệ thống
- **macOS**: 13.0 (Ventura) trở lên
- **Xcode**: 15.0 trở lên
- **iOS Simulator**: iOS 17.0 trở lên
- **Swift**: 5.0 trở lên

### Cài đặt Xcode
1. Mở App Store
2. Tìm kiếm "Xcode"
3. Nhấn "Get" hoặc "Install"
4. Chờ quá trình cài đặt hoàn tất (có thể mất 30-60 phút)

### Cài đặt Command Line Tools
```bash
xcode-select --install
```

## Bước 2: Tải và cấu hình dự án

### 1. Tải dự án
```bash
# Clone repository hoặc tải file ZIP
git clone <repository-url>
cd ios_app
```

### 2. Mở dự án trong Xcode
```bash
open EmployeeManagementApp.xcodeproj
```

### 3. Cấu hình Bundle Identifier
1. Chọn project "EmployeeManagementApp" trong Navigator
2. Chọn target "EmployeeManagementApp"
3. Vào tab "Signing & Capabilities"
4. Thay đổi Bundle Identifier thành tên duy nhất (ví dụ: `com.yourcompany.employeemanagement`)

### 4. Cấu hình Team
1. Trong tab "Signing & Capabilities"
2. Chọn Team của bạn từ dropdown
3. Nếu chưa có team, tạo Apple ID Developer Account

## Bước 3: Cấu hình kết nối server

### 1. Cập nhật URL server
Mở file `EmployeeManagementApp/Models/Models.swift` và tìm dòng:
```swift
static let baseURL = "http://localhost" // Thay đổi theo server của bạn
```

Thay đổi thành URL server thực tế:
```swift
static let baseURL = "https://your-domain.com"
```

### 2. Cấu hình HTTPS (khuyến nghị)
Đảm bảo server của bạn hỗ trợ HTTPS để bảo mật dữ liệu.

### 3. Kiểm tra API endpoints
Đảm bảo các API endpoints sau hoạt động:
- `POST /login_process.php`
- `POST /clock_in_out.php`
- `GET /attendance.php`
- `GET /api_monthly_data.php`
- `GET /api_notifications.php`
- `POST /api_chat.php`

## Bước 4: Build và chạy ứng dụng

### 1. Chọn target device
- **Simulator**: Chọn iPhone simulator từ dropdown
- **Physical Device**: Kết nối iPhone và chọn device

### 2. Build ứng dụng
```bash
# Cách 1: Sử dụng Xcode
# Nhấn Cmd+R hoặc nút Play

# Cách 2: Sử dụng command line
xcodebuild -project EmployeeManagementApp.xcodeproj -scheme EmployeeManagementApp -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### 3. Chạy ứng dụng
- Trong Xcode: Nhấn Cmd+R
- Trong Simulator: Ứng dụng sẽ tự động mở

## Bước 5: Cấu hình cho thiết bị thật

### 1. Tạo Apple Developer Account
1. Truy cập [developer.apple.com](https://developer.apple.com)
2. Đăng ký tài khoản Developer ($99/năm)
3. Xác thực email và thanh toán

### 2. Cấu hình Provisioning Profile
1. Trong Xcode, chọn target device
2. Vào "Signing & Capabilities"
3. Chọn "Automatically manage signing"
4. Chọn Team của bạn

### 3. Build cho thiết bị thật
1. Kết nối iPhone với Mac
2. Chọn device trong Xcode
3. Nhấn Cmd+R để build và cài đặt

## Bước 6: Cấu hình nâng cao

### 1. Push Notifications (tùy chọn)
1. Vào "Signing & Capabilities"
2. Nhấn "+ Capability"
3. Chọn "Push Notifications"
4. Cấu hình trong server

### 2. Background App Refresh
1. Vào "Signing & Capabilities"
2. Nhấn "+ Capability"
3. Chọn "Background Modes"
4. Chọn "Background fetch"

### 3. Camera và Photo Library
Đã được cấu hình sẵn trong `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh đại diện</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh để chọn ảnh đại diện</string>
```

## Troubleshooting

### Lỗi thường gặp

#### 1. "No such module" error
```bash
# Clean build folder
Product > Clean Build Folder (Cmd+Shift+K)

# Reset simulator
Device > Erase All Content and Settings
```

#### 2. "Code signing error"
1. Kiểm tra Bundle Identifier
2. Kiểm tra Team selection
3. Xóa và tạo lại Provisioning Profile

#### 3. "Network request failed"
1. Kiểm tra URL server
2. Kiểm tra network connectivity
3. Kiểm tra CORS settings trên server

#### 4. "TOTP validation failed"
1. Kiểm tra thời gian thiết bị
2. Kiểm tra secret key
3. Kiểm tra time window

### Debug tips

#### 1. Sử dụng Console
```swift
print("Debug message: \(variable)")
```

#### 2. Sử dụng Breakpoints
1. Nhấn vào số dòng để tạo breakpoint
2. Chạy ứng dụng
3. Kiểm tra giá trị variables

#### 3. Network debugging
```swift
// Trong NetworkManager.swift
print("API Response: \(responseString)")
```

## Cấu hình server

### 1. CORS Headers
Thêm vào server PHP:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

### 2. SSL Certificate
Đảm bảo server có SSL certificate hợp lệ cho HTTPS.

### 3. API Rate Limiting
Cấu hình rate limiting để tránh spam requests.

## Deploy lên App Store

### 1. Archive ứng dụng
1. Chọn "Any iOS Device" làm target
2. Product > Archive
3. Chờ quá trình build hoàn tất

### 2. Upload lên App Store Connect
1. Mở Organizer (Window > Organizer)
2. Chọn archive vừa tạo
3. Nhấn "Distribute App"
4. Chọn "App Store Connect"
5. Follow hướng dẫn

### 3. Cấu hình App Store Connect
1. Truy cập [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Tạo app mới
3. Điền thông tin app
4. Upload screenshots và metadata
5. Submit for review

## Hỗ trợ

Nếu gặp vấn đề trong quá trình cài đặt:

1. **Kiểm tra logs**: Xem Console trong Xcode
2. **Tìm kiếm lỗi**: Sử dụng Google với error message
3. **Tạo issue**: Tạo issue trên GitHub repository
4. **Liên hệ support**: Gửi email cho team phát triển

---

**Lưu ý**: Hướng dẫn này dành cho phiên bản demo. Để deploy production, cần thêm các bước bảo mật và tối ưu hóa khác.
