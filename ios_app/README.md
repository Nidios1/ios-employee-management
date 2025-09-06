# MyApp - iOS Application

Đây là một ứng dụng iOS đơn giản được tạo để test build IPA qua GitHub Actions.

## Cấu trúc Project

```
ios_app/
├── MyApp.xcodeproj/          # Xcode project file
├── MyApp/                    # Source code
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Info.plist
│   ├── Base.lproj/
│   │   ├── Main.storyboard
│   │   └── LaunchScreen.storyboard
│   └── Assets.xcassets/
├── .github/workflows/
│   └── build.yml             # GitHub Actions workflow
└── ExportOptions.plist       # Export configuration
```

## Tính năng

- ✅ App iOS đơn giản với "Hello World"
- ✅ GitHub Actions để build IPA tự động
- ✅ Export IPA file để deploy

## Cách sử dụng

1. Push code lên GitHub
2. GitHub Actions sẽ tự động build IPA
3. Download IPA từ Artifacts

## Build locally

```bash
cd ios_app
xcodebuild -project MyApp.xcodeproj -scheme MyApp -configuration Release -destination 'generic/platform=iOS' -archivePath MyApp.xcarchive archive
xcodebuild -exportArchive -archivePath MyApp.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist
```
