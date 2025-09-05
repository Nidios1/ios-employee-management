# Hướng dẫn sửa lỗi project iOS

## Vấn đề hiện tại
File `EmployeeManagementApp.xcodeproj` bị hỏng và không tương thích với Xcode trên GitHub Actions.

## Giải pháp: Tạo lại project structure

### Bước 1: Xóa project cũ
1. Vào repository trên GitHub
2. Vào folder `ios_app/`
3. Xóa folder `EmployeeManagementApp.xcodeproj`
4. Xóa folder `EmployeeManagementApp/`

### Bước 2: Upload project mới
1. Click **"Add file"** → **"Upload files"**
2. Upload các files sau:

#### Files cần upload:
```
ios_app/
├── EmployeeManagementApp.xcodeproj/
│   └── project.pbxproj
├── EmployeeManagementApp/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewControllers/
│   │   ├── LoginViewController.swift
│   │   ├── HomeViewController.swift
│   │   ├── AttendanceViewController.swift
│   │   ├── SalaryViewController.swift
│   │   ├── NotificationsViewController.swift
│   │   ├── ChatViewController.swift
│   │   ├── ProfileViewController.swift
│   │   └── MainTabBarController.swift
│   ├── Managers/
│   │   ├── NetworkManager.swift
│   │   ├── AuthManager.swift
│   │   └── TOTPManager.swift
│   ├── Models/
│   │   └── Models.swift
│   ├── Assets.xcassets/
│   │   ├── Contents.json
│   │   ├── AppIcon.appiconset/
│   │   └── AccentColor.colorset/
│   ├── Main.storyboard
│   ├── LaunchScreen.storyboard
│   └── Info.plist
├── ExportOptions.plist
├── Podfile
├── Gemfile
└── fastlane/
    └── Fastfile
```

### Bước 3: Commit changes
1. **Commit message**: "Fix iOS project structure"
2. **Description**: "Replace corrupted project with working structure"
3. Click **"Commit changes"**

### Bước 4: Test build
1. Vào tab **"Actions"**
2. Click **"Run workflow"**
3. Xem build có thành công không

## Lưu ý quan trọng

### Nếu vẫn lỗi:
1. Kiểm tra scheme name
2. Kiểm tra bundle identifier
3. Kiểm tra deployment target

### Nếu thành công:
1. IPA file sẽ được tạo
2. Có thể tải từ GitHub Artifacts
3. Có thể tạo GitHub Release

## Các bước tiếp theo

Sau khi fix xong:
1. **Test build** để đảm bảo hoạt động
2. **Cấu hình App Center** (nếu cần)
3. **Deploy lên thiết bị** để test

---

**Lưu ý**: Project mới này đã được tối ưu hóa để tương thích với GitHub Actions và Xcode trên macOS runners.
