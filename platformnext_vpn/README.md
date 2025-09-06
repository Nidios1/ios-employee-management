# Platform Next - Unlimited VPN

Ứng dụng VPN được phát triển bằng Flutter với khả năng kết nối đến nhiều server trên toàn thế giới.

## Tính năng

- 🌍 Kết nối đến 200+ quốc gia
- 🚀 Tốc độ cao và ổn định
- 🔒 Bảo mật cao với mã hóa end-to-end
- 🎮 Chế độ Gaming tối ưu
- 📱 Giao diện thân thiện
- 🔄 Tự động kết nối lại
- 📊 Theo dõi thống kê sử dụng

## Cài đặt

### Yêu cầu hệ thống

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Xcode >= 15.0 (cho iOS)
- Android Studio (cho Android)

### Cài đặt dependencies

```bash
flutter pub get
```

### Chạy ứng dụng

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Build IPA cho iOS

### Cách 1: Sử dụng GitHub Actions (Khuyến nghị)

1. Fork repository này
2. Thêm các secrets sau vào GitHub repository:
   - `BUILD_CERTIFICATE_BASE64`: Certificate .p12 được encode base64
   - `P12_PASSWORD`: Mật khẩu của file .p12
   - `BUILD_PROVISION_PROFILE_BASE64`: Provisioning profile được encode base64
   - `KEYCHAIN_PASSWORD`: Mật khẩu keychain
   - `APP_STORE_CONNECT_API_KEY`: API key cho App Store Connect
   - `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID
   - `APP_STORE_CONNECT_KEY_ID`: Key ID

3. Push code lên branch `main` hoặc `develop`
4. GitHub Actions sẽ tự động build và tạo IPA file

### Cách 2: Build local

```bash
# Build iOS
flutter build ios --release

# Tạo IPA
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination generic/platform=iOS \
  -archivePath Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath Runner.xcarchive \
  -exportPath . \
  -exportOptionsPlist ExportOptions.plist
```

## Cấu hình

### iOS

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Cấu hình Bundle Identifier: `com.platformnext.dev`
3. Thêm VPN capabilities
4. Cấu hình signing & capabilities

### Android

1. Mở `android/app/build.gradle`
2. Cấu hình `applicationId` và `versionName`
3. Thêm VPN permissions

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── screens/                  # Các màn hình
├── widgets/                  # Widgets tái sử dụng
├── services/                 # Business logic
├── models/                   # Data models
└── utils/                    # Utilities

assets/
├── connection/               # Icons kết nối
├── core/                    # Database files
├── custom/                  # Server configs
├── flags/                   # Country flags
├── fonts/                   # Font files
└── images/                  # Images
```

## Dependencies chính

- `provider`: State management
- `connectivity_plus`: Kiểm tra kết nối mạng
- `shared_preferences`: Lưu trữ local
- `firebase_core`: Firebase integration
- `qr_code_scanner`: Quét QR code
- `image_picker`: Chọn hình ảnh
- `permission_handler`: Quản lý quyền

## License

MIT License - Xem file LICENSE để biết thêm chi tiết.

## Đóng góp

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## Liên hệ

- Email: support@platformnext.com
- Website: https://platformnext.com
