#!/bin/bash
# Script để khởi tạo Flutter project từ IPA đã phân tích

echo "🚀 Khởi tạo Flutter project PPAPIKey Mobile..."

# Kiểm tra Flutter đã cài đặt chưa
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter chưa được cài đặt. Vui lòng cài đặt Flutter SDK trước."
    echo "📖 Hướng dẫn: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Kiểm tra Dart đã cài đặt chưa
if ! command -v dart &> /dev/null; then
    echo "❌ Dart chưa được cài đặt. Vui lòng cài đặt Dart SDK trước."
    exit 1
fi

echo "✅ Flutter và Dart đã được cài đặt"

# Di chuyển vào thư mục dự án
cd PPAPIKey_Mobile_Project

echo "📦 Cài đặt dependencies..."
flutter pub get

echo "🔧 Cấu hình iOS project..."
cd ios
pod install
cd ..

echo "🏗️ Build project..."
flutter build ios --debug --no-codesign

echo "✅ Hoàn thành khởi tạo project!"
echo ""
echo "📋 Các bước tiếp theo:"
echo "1. Mở ios/Runner.xcworkspace trong Xcode"
echo "2. Cấu hình signing và provisioning profile"
echo "3. Build và test trên simulator/device"
echo "4. Setup GitHub Actions với Apple Developer credentials"
echo ""
echo "📁 Cấu trúc project:"
echo "├── lib/                    # Flutter source code"
echo "├── assets/                 # Images, fonts, audio, translations"
echo "├── ios/                    # iOS native configuration"
echo "├── android/                # Android native configuration"
echo "├── .github/workflows/      # GitHub Actions"
echo "└── docs/                   # Documentation"
echo ""
echo "🔗 GitHub Actions đã được cấu hình sẵn tại .github/workflows/build.yml"
echo "🔐 Cần thiết lập các secrets sau trong GitHub:"
echo "   - APPLE_ID"
echo "   - APPLE_ID_PASSWORD"
echo "   - CERTIFICATE_P12"
echo "   - CERTIFICATE_PASSWORD"
echo "   - PROVISIONING_PROFILE"
echo "   - TEAM_ID"
