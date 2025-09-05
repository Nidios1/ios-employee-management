# Hướng dẫn Deploy iOS App lên App Center qua GitHub Actions

## 🎯 Tổng quan

Hướng dẫn này sẽ giúp bạn:
1. Tự động build IPA file qua GitHub Actions
2. Deploy lên Microsoft App Center
3. Phân phối app cho testers
4. Tạo GitHub Releases tự động

## 📋 Yêu cầu

### 1. Tài khoản cần thiết
- ✅ GitHub account
- ✅ Microsoft App Center account
- ✅ Apple Developer account (để tạo certificates)

### 2. Công cụ cần thiết
- ✅ Xcode (để tạo certificates)
- ✅ Fastlane (đã được cấu hình)
- ✅ App Center CLI

## 🚀 Bước 1: Chuẩn bị App Center

### 1.1 Tạo App trong App Center
1. Truy cập [appcenter.ms](https://appcenter.ms)
2. Đăng nhập với Microsoft account
3. Nhấn "Add new" → "Add new app"
4. Chọn "iOS" platform
5. Nhập tên app: `EmployeeManagementApp`
6. Chọn "Objective-C/Swift" OS
7. Nhấn "Add new app"

### 1.2 Lấy thông tin cần thiết
Sau khi tạo app, lấy các thông tin sau:
- **Owner Name**: Tên organization hoặc username
- **App Name**: Tên app (ví dụ: `EmployeeManagementApp`)
- **API Token**: Vào Settings → API Tokens → New API Token

### 1.3 Tạo Distribution Group
1. Vào app → Distribute → Groups
2. Nhấn "New group"
3. Tên group: `Testers`
4. Thêm email testers
5. Lưu lại tên group

## 🔐 Bước 2: Cấu hình Apple Certificates

### 2.1 Tạo Certificates
1. Mở Xcode
2. Vào Preferences → Accounts
3. Thêm Apple ID của bạn
4. Vào "Manage Certificates"
5. Tạo "iOS Distribution" certificate

### 2.2 Tạo Provisioning Profile
1. Truy cập [developer.apple.com](https://developer.apple.com)
2. Vào Certificates, Identifiers & Profiles
3. Tạo App ID: `com.yourcompany.EmployeeManagementApp`
4. Tạo Provisioning Profile cho Development/Distribution

### 2.3 Cấu hình trong Xcode
1. Mở project trong Xcode
2. Chọn target "EmployeeManagementApp"
3. Vào "Signing & Capabilities"
4. Chọn Team và Bundle Identifier
5. Enable "Automatically manage signing"

## 🔧 Bước 3: Cấu hình GitHub Secrets

### 3.1 Vào GitHub Repository Settings
1. Truy cập repository trên GitHub
2. Vào Settings → Secrets and variables → Actions
3. Nhấn "New repository secret"

### 3.2 Thêm các Secrets sau:

| Secret Name | Value | Mô tả |
|-------------|-------|-------|
| `APPCENTER_API_TOKEN` | `your-api-token` | API token từ App Center |
| `APPCENTER_OWNER_NAME` | `your-username` | Owner name trong App Center |
| `APPCENTER_APP_NAME` | `EmployeeManagementApp` | Tên app trong App Center |
| `APPCENTER_DISTRIBUTION_GROUP` | `Testers` | Tên group testers |
| `TEAM_ID` | `YOUR_TEAM_ID` | Apple Team ID |
| `GITHUB_TOKEN` | `auto-generated` | Tự động tạo bởi GitHub |

### 3.3 Lấy Apple Team ID
1. Vào [developer.apple.com](https://developer.apple.com)
2. Vào Account → Membership
3. Copy Team ID (10 ký tự)

## 📱 Bước 4: Cấu hình Project

### 4.1 Cập nhật Bundle Identifier
1. Mở `EmployeeManagementApp.xcodeproj`
2. Chọn target "EmployeeManagementApp"
3. Vào "Signing & Capabilities"
4. Thay đổi Bundle Identifier thành: `com.yourcompany.EmployeeManagementApp`

### 4.2 Cập nhật ExportOptions.plist
Mở file `ExportOptions.plist` và thay đổi:
```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- Thay bằng Team ID thực tế -->

<key>provisioningProfiles</key>
<dict>
    <key>com.yourcompany.EmployeeManagementApp</key>
    <string>YOUR_PROVISIONING_PROFILE_NAME</string>  <!-- Thay bằng tên profile thực tế -->
</dict>
```

### 4.3 Cập nhật Constants
Mở `Models/Models.swift` và cập nhật:
```swift
static let baseURL = "https://your-server.com"  // URL server thực tế
```

## 🚀 Bước 5: Deploy

### 5.1 Push code lên GitHub
```bash
git add .
git commit -m "Add App Center deployment"
git push origin main
```

### 5.2 Kiểm tra GitHub Actions
1. Vào repository trên GitHub
2. Vào tab "Actions"
3. Xem workflow "Build and Deploy to App Center"
4. Kiểm tra logs nếu có lỗi

### 5.3 Kiểm tra App Center
1. Vào App Center
2. Vào app của bạn
3. Vào "Distribute" → "Releases"
4. Xem build mới được tạo

## 📱 Bước 6: Test trên thiết bị

### 6.1 Cài đặt App Center
1. Tải App Center app từ App Store
2. Đăng nhập với Microsoft account
3. Vào app của bạn

### 6.2 Cài đặt app
1. Vào "Releases"
2. Chọn build mới nhất
3. Nhấn "Install"
4. Follow hướng dẫn cài đặt

## 🔄 Bước 7: Tự động hóa

### 7.1 Trigger build
Workflow sẽ tự động chạy khi:
- Push code lên branch `main` hoặc `develop`
- Tạo Pull Request
- Chạy manual từ GitHub Actions

### 7.2 Cấu hình thêm
Có thể thêm các trigger khác:
```yaml
on:
  schedule:
    - cron: '0 0 * * 1'  # Chạy mỗi thứ 2 hàng tuần
  release:
    types: [published]   # Khi tạo release
```

## 🐛 Troubleshooting

### Lỗi thường gặp

#### 1. "Code signing error"
```bash
# Kiểm tra certificates
security find-identity -v -p codesigning

# Kiểm tra provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

#### 2. "App Center upload failed"
- Kiểm tra API token
- Kiểm tra app name và owner name
- Kiểm tra network connection

#### 3. "Build failed"
- Kiểm tra Xcode version
- Kiểm tra iOS deployment target
- Kiểm tra dependencies

### Debug tips

#### 1. Xem logs chi tiết
```bash
# Trong GitHub Actions
- name: Debug info
  run: |
    echo "Xcode version:"
    xcodebuild -version
    echo "Available simulators:"
    xcrun simctl list devices
```

#### 2. Test local
```bash
# Test fastlane local
cd ios_app
bundle exec fastlane appcenter
```

#### 3. Kiểm tra certificates
```bash
# List certificates
security find-identity -v -p codesigning
```

## 📊 Monitoring

### 1. GitHub Actions
- Xem build status
- Download artifacts
- Xem logs chi tiết

### 2. App Center
- Xem download statistics
- Crash reports
- User feedback

### 3. GitHub Releases
- Download IPA files
- Release notes
- Version history

## 🔧 Advanced Configuration

### 1. Multiple environments
```yaml
strategy:
  matrix:
    environment: [development, staging, production]
```

### 2. Different app versions
```yaml
env:
  APP_VERSION: ${{ matrix.environment == 'production' && '1.0.0' || '1.0.0-beta' }}
```

### 3. Conditional deployment
```yaml
- name: Deploy to App Center
  if: github.ref == 'refs/heads/main'
  run: |
    # Deploy only on main branch
```

## 📝 Kết luận

Sau khi hoàn thành các bước trên, bạn sẽ có:

✅ **Tự động build IPA** mỗi khi push code
✅ **Deploy lên App Center** tự động
✅ **Phân phối cho testers** dễ dàng
✅ **GitHub Releases** với IPA files
✅ **Monitoring và logs** đầy đủ

**Lưu ý**: Đây là setup cơ bản. Có thể tùy chỉnh thêm theo nhu cầu cụ thể của dự án.

