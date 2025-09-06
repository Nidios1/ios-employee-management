# SimpleApp - SwiftUI iOS Application

Đây là một ứng dụng iOS SwiftUI siêu đơn giản được tạo để test build qua GitHub Actions.

## Cấu trúc Project

```
ios_app/
├── SimpleApp.xcodeproj/      # Xcode project file
├── SimpleApp/                # Source code
│   ├── SimpleAppApp.swift    # App entry point
│   ├── ContentView.swift     # Main view
│   ├── Info.plist           # App configuration
│   └── Assets.xcassets/     # App icons và colors
├── .github/workflows/
│   └── build.yml            # GitHub Actions workflow
└── README.md                # This file
```

## Tính năng

- ✅ SwiftUI app đơn giản với "Hello, world! 🎉"
- ✅ GitHub Actions để build tự động
- ✅ Không cần code signing (build cho simulator)
- ✅ Cấu trúc project đơn giản nhất

## Cách sử dụng

1. Push code lên GitHub
2. GitHub Actions sẽ tự động build
3. Xem kết quả build trong Actions tab

## Build locally

```bash
cd ios_app
xcodebuild -project SimpleApp.xcodeproj -scheme SimpleApp -configuration Release -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Lưu ý

- Project này sử dụng SwiftUI (đơn giản hơn UIKit)
- Build cho iOS Simulator (không cần code signing)
- Cấu trúc project tối giản nhất có thể
