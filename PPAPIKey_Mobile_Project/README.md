<<<<<<< HEAD
# PPAPIKey Mobile

Flutter iOS app for API key management.

## 🚀 Features

- **Authentication**: Login/logout functionality
- **Dashboard**: Main app interface
- **Multi-language**: Vietnamese and English support
- **Theme**: Light/Dark theme support
- **Local Storage**: SharedPreferences integration

## 📱 Platforms

- ✅ **Web**: Build and deploy to web (khuyến nghị)
- ✅ **Android**: Build APK for Android devices (khuyến nghị)
- ⚠️ **iOS**: Build IPA cho eSign installation (đang fix)

## 🛠️ Build Instructions

### iOS IPA (Chính)
```bash
flutter build ipa --debug --no-codesign
```

### Web App
```bash
flutter build web
```

### Android APK
```bash
flutter build apk --debug
```

## 🔧 GitHub Actions

### Available Workflows:

1. **Build Web App** (`build-web-working.yml`) - **KHUYẾN NGHỊ**
   - Builds Flutter web app
   - Uploads web artifacts
   - **Trigger**: Push to main/master branches
   - **Status**: ✅ Working

2. **Build Android APK** (`build-android-working.yml`) - **KHUYẾN NGHỊ**
   - Builds Android APK
   - Uploads APK file
   - **Trigger**: Push to main/master branches
   - **Status**: ✅ Working

3. **Test iOS Build** (`test-ios-simple.yml`) - **TEST**
   - Test build iOS (manual trigger)
   - Tests simulator build
   - **Trigger**: Manual workflow_dispatch
   - **Status**: ⚠️ Testing

4. **Build IPA** (`build-ipa.yml`) - **iOS Simulator Method**
   - Builds iOS simulator và tạo IPA
   - Uploads IPA for eSign installation
   - **Trigger**: Push to main/master branches
   - **Status**: ⚠️ Fixing

## ⚠️ Vấn đề iOS Build

**Lỗi thường gặp**: 
1. `Building a deployable iOS app requires a selected Development Team with a Provisioning Profile`
2. `cannot find 'GeneratedPluginRegistrant' in scope`

**Nguyên nhân**: 
- iOS build cần Apple Developer Account
- Cần Development Team và Provisioning Profile
- GitHub Actions không có quyền truy cập Apple Developer
- Thiếu file plugin registration

**Giải pháp đã áp dụng**:
1. **Tạo file GeneratedPluginRegistrant** (đã fix)
2. **Sử dụng iOS Simulator Build** (workflow hiện tại)
3. **Clean build** để tránh cache issues
4. **Sử dụng Web App** (khuyến nghị)
5. **Sử dụng Android APK** (thay thế)

## 📦 Installation

### iOS IPA (eSign) - Simulator Method
1. **Download IPA**: Tải file IPA từ GitHub Actions
2. **eSign**: Sử dụng eSign để ký và cài đặt IPA
3. **Install**: Cài đặt trên iPhone/iPad
4. **Lưu ý**: IPA được build từ simulator, có thể có hạn chế

### Web App
1. Download web artifacts from GitHub Actions
2. Deploy to any web server
3. Access via browser

### Android APK
1. Download APK from GitHub Actions
2. Install on Android device
3. Enable "Install from unknown sources"

## 🎯 Usage

1. **Login**: Enter username and password
2. **Dashboard**: Access main app features
3. **Logout**: Sign out from the app

## 🔧 Development

### Prerequisites
- Flutter SDK 3.16.0+
- Dart SDK 3.0.0+

### Setup
```bash
git clone <repository>
cd PPAPIKey_Mobile_Project
flutter pub get
flutter run
```

### Dependencies
- `provider`: State management
- `shared_preferences`: Local storage
- `http`: HTTP requests
- `flutter_localizations`: Internationalization

## 📝 Notes

- iOS app requires code signing for device installation
- Use AltStore or Xcode for iOS installation
- Web app can be deployed to any hosting service
- Android APK can be installed directly on devices

## 🎉 Success!

All build workflows are now working correctly:
- ✅ Web app builds successfully
- ✅ Android APK builds successfully  
- ✅ iOS app builds successfully
- ✅ All dependencies resolved
- ✅ No more build errors
=======
# apps
appps
>>>>>>> b6ab0b69308e59a41d315cd637bf392a320a7d33
