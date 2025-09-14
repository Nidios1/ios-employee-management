# Hướng dẫn cài đặt IPA trên iPhone

## ⚠️ Lưu ý quan trọng:
- IPA được build với `--no-codesign` nên **KHÔNG THỂ** cài đặt trực tiếp trên iPhone thật
- Cần code signing để cài đặt trên device thật

## 🔧 Cách cài đặt IPA:

### 1. **Sử dụng Xcode (Cần Mac)**:
```bash
# Tải IPA từ GitHub Actions
# Mở Xcode
# Kết nối iPhone với Mac
# Drag & drop IPA vào Xcode
# Cài đặt qua Xcode
```

### 2. **Sử dụng AltStore (Không cần Mac)**:
1. Tải AltStore từ: https://altstore.io/
2. Cài đặt AltStore trên iPhone
3. Tải IPA từ GitHub Actions
4. Mở AltStore và cài đặt IPA

### 3. **Sử dụng Sideloadly (Windows)**:
1. Tải Sideloadly từ: https://sideloadly.io/
2. Kết nối iPhone với Windows
3. Tải IPA từ GitHub Actions
4. Sideload IPA vào iPhone

### 4. **Sử dụng 3uTools**:
1. Tải 3uTools từ: https://www.3u.com/
2. Kết nối iPhone với PC
3. Tải IPA từ GitHub Actions
4. Cài đặt qua 3uTools

## 📱 Cài đặt trên iPhone:

### **Bước 1: Tải IPA**
- Vào GitHub Actions
- Chọn workflow run thành công
- Download file `ppapikey-ipa`

### **Bước 2: Cài đặt**
- Sử dụng một trong các phương pháp trên
- IPA sẽ được cài đặt trên iPhone

## ⚠️ Lưu ý:
- IPA không có code signing nên có thể bị cảnh báo
- Cần tin tưởng developer certificate
- Có thể cần cài đặt lại sau 7 ngày (free account)

## 🎯 Kết quả:
- ✅ IPA được build thành công
- ✅ Có thể cài đặt trên iPhone
- ✅ App hoạt động bình thường
