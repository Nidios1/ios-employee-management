# TestApp - iOS SwiftUI Tối Giản

Đây là project iOS SwiftUI **siêu đơn giản** nhất có thể để test build.

## Cấu trúc Project

```
ios_app/
├── TestApp.xcodeproj/        # Project file tối giản
├── TestApp/                  # Source code
│   ├── TestAppApp.swift      # App entry point
│   ├── ContentView.swift     # "Hello World! 🎉"
│   └── Info.plist           # App config
├── .github/workflows/
│   └── build.yml            # GitHub Actions
└── README.md                # This file
```

## Tính năng

- ✅ **Chỉ 2 file Swift** - Tối giản nhất
- ✅ **Không có Assets** - Không cần icon
- ✅ **SwiftUI đơn giản** - Chỉ hiển thị text
- ✅ **Code signing tắt** - Build cho simulator
- ✅ **Project structure chuẩn** - Không có lỗi cấu trúc

## Build

```bash
cd ios_app
xcodebuild -project TestApp.xcodeproj -scheme TestApp -configuration Release -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Lưu ý

- Project này **tối giản nhất** có thể
- Chỉ có **"Hello World! 🎉"** text
- **Không có Assets.xcassets** để tránh lỗi
- **Project.pbxproj** được tối ưu hóa
