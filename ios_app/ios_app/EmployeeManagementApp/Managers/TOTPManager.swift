import Foundation
import CryptoKit
import CommonCrypto

class TOTPManager {
    static let shared = TOTPManager()
    
    private init() {}
    
    // MARK: - TOTP Generation
    func generateTOTP(secret: String, timeStep: Int = 30, digits: Int = 6) -> String? {
        guard let secretData = base32Decode(secret) else {
            return nil
        }
        
        let time = UInt64(Date().timeIntervalSince1970) / UInt64(timeStep)
        let timeData = withUnsafeBytes(of: time.bigEndian) { Data($0) }
        
        let hmac = HMAC<SHA1>.authenticationCode(for: timeData, using: SymmetricKey(data: secretData))
        let hmacData = Data(hmac)
        
        let offset = Int(hmacData.last! & 0x0f)
        let truncated = hmacData.subdata(in: offset..<offset + 4)
        let code = truncated.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        let totp = code % UInt32(pow(10, Double(digits)))
        return String(format: "%0\(digits)d", totp)
    }
    
    // MARK: - TOTP Validation
    func validateTOTP(secret: String, code: String, timeStep: Int = 30, window: Int = 1) -> Bool {
        guard let secretData = base32Decode(secret) else {
            return false
        }
        
        let currentTime = UInt64(Date().timeIntervalSince1970) / UInt64(timeStep)
        
        // Check current time and surrounding windows
        for i in -window...window {
            let time = currentTime + UInt64(i)
            let timeData = withUnsafeBytes(of: time.bigEndian) { Data($0) }
            
            let hmac = HMAC<SHA1>.authenticationCode(for: timeData, using: SymmetricKey(data: secretData))
            let hmacData = Data(hmac)
            
            let offset = Int(hmacData.last! & 0x0f)
            let truncated = hmacData.subdata(in: offset..<offset + 4)
            let generatedCode = truncated.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            
            let totp = generatedCode % UInt32(pow(10, Double(6)))
            let totpString = String(format: "%06d", totp)
            
            if totpString == code {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - QR Code Generation
    func generateQRCodeData(secret: String, accountName: String, issuer: String = "Employee Management") -> String {
        let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? secret
        let encodedAccount = accountName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? accountName
        let encodedIssuer = issuer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? issuer
        
        return "otpauth://totp/\(encodedIssuer):\(encodedAccount)?secret=\(encodedSecret)&issuer=\(encodedIssuer)&algorithm=SHA1&digits=6&period=30"
    }
    
    // MARK: - Base32 Decoding
    private func base32Decode(_ string: String) -> Data? {
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let string = string.uppercased().replacingOccurrences(of: " ", with: "")
        
        guard !string.isEmpty else { return nil }
        
        var bits = 0
        var value = 0
        var data = Data()
        
        for char in string {
            guard let index = base32Alphabet.firstIndex(of: char) else { continue }
            let charValue = base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
            
            value = (value << 5) | charValue
            bits += 5
            
            if bits >= 8 {
                data.append(UInt8((value >> (bits - 8)) & 0xFF))
                bits -= 8
            }
        }
        
        return data
    }
    
    // MARK: - Time Remaining
    func getTimeRemaining() -> Int {
        let timeStep: Int = 30
        let currentTime = Int(Date().timeIntervalSince1970)
        return timeStep - (currentTime % timeStep)
    }
    
    // MARK: - Generate Random Secret
    func generateRandomSecret() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let length = 32
        var secret = ""
        
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<characters.count)
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            secret.append(character)
        }
        
        return secret
    }
}

// MARK: - TOTP Extensions
extension TOTPManager {
    func formatTimeRemaining(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes):\(String(format: "%02d", remainingSeconds))"
        }
    }
    
    func getProgressPercentage() -> Float {
        let timeRemaining = getTimeRemaining()
        return Float(30 - timeRemaining) / 30.0
    }
}
