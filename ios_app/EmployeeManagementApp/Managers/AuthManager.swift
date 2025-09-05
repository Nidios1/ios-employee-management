import Foundation
import UIKit

class AuthManager {
    static let shared = AuthManager()
    
    private let userDefaults = UserDefaults.standard
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Authentication State
    var isLoggedIn: Bool {
        return userDefaults.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn)
    }
    
    var currentUser: User? {
        guard isLoggedIn else { return nil }
        
        return User(
            id: userDefaults.integer(forKey: Constants.UserDefaultsKeys.userId),
            username: userDefaults.string(forKey: Constants.UserDefaultsKeys.username) ?? "",
            fullName: userDefaults.string(forKey: Constants.UserDefaultsKeys.fullName) ?? "",
            email: userDefaults.string(forKey: Constants.UserDefaultsKeys.email) ?? "",
            phone: nil,
            position: nil,
            department: nil,
            employeeId: nil,
            avatarUrl: userDefaults.string(forKey: Constants.UserDefaultsKeys.avatarUrl),
            isAdmin: userDefaults.bool(forKey: Constants.UserDefaultsKeys.isAdmin),
            systemId: userDefaults.integer(forKey: Constants.UserDefaultsKeys.systemId),
            lastLogin: userDefaults.string(forKey: Constants.UserDefaultsKeys.lastLogin)
        )
    }
    
    var currentSystemId: Int {
        return userDefaults.integer(forKey: Constants.UserDefaultsKeys.systemId)
    }
    
    var currentSystemName: String {
        return userDefaults.string(forKey: Constants.UserDefaultsKeys.systemName) ?? ""
    }
    
    // MARK: - Login
    func login(system: String, username: String, password: String, otp: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        networkManager.login(system: system, username: username, password: password, otp: otp) { [weak self] result in
            switch result {
            case .success(let response):
                if response.success {
                    // Save user data to UserDefaults
                    self?.saveUserData(response)
                    completion(.success(true))
                } else {
                    completion(.failure(APIError(message: response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveUserData(_ response: LoginResponse) {
        guard let user = response.user else { return }
        
        userDefaults.set(true, forKey: Constants.UserDefaultsKeys.isLoggedIn)
        userDefaults.set(user.id, forKey: Constants.UserDefaultsKeys.userId)
        userDefaults.set(user.username, forKey: Constants.UserDefaultsKeys.username)
        userDefaults.set(user.fullName, forKey: Constants.UserDefaultsKeys.fullName)
        userDefaults.set(user.email, forKey: Constants.UserDefaultsKeys.email)
        userDefaults.set(user.avatarUrl, forKey: Constants.UserDefaultsKeys.avatarUrl)
        userDefaults.set(user.isAdmin, forKey: Constants.UserDefaultsKeys.isAdmin)
        userDefaults.set(user.systemId, forKey: Constants.UserDefaultsKeys.systemId)
        userDefaults.set(user.lastLogin, forKey: Constants.UserDefaultsKeys.lastLogin)
        
        if let system = response.system {
            userDefaults.set(system.name, forKey: Constants.UserDefaultsKeys.systemName)
        }
        
        userDefaults.synchronize()
    }
    
    // MARK: - Logout
    func logout(completion: @escaping () -> Void) {
        // Clear all stored data
        let keys = [
            Constants.UserDefaultsKeys.isLoggedIn,
            Constants.UserDefaultsKeys.userId,
            Constants.UserDefaultsKeys.username,
            Constants.UserDefaultsKeys.fullName,
            Constants.UserDefaultsKeys.email,
            Constants.UserDefaultsKeys.systemId,
            Constants.UserDefaultsKeys.systemName,
            Constants.UserDefaultsKeys.avatarUrl,
            Constants.UserDefaultsKeys.isAdmin,
            Constants.UserDefaultsKeys.lastLogin
        ]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
        
        userDefaults.synchronize()
        completion()
    }
    
    // MARK: - Session Management
    func checkSessionValidity() -> Bool {
        guard isLoggedIn else { return false }
        
        // Check if session is still valid (optional: implement session timeout)
        return true
    }
    
    func refreshSession(completion: @escaping (Bool) -> Void) {
        // Implement session refresh logic if needed
        completion(true)
    }
    
    // MARK: - User Profile Updates
    func updateUserProfile(_ user: User) {
        userDefaults.set(user.fullName, forKey: Constants.UserDefaultsKeys.fullName)
        userDefaults.set(user.email, forKey: Constants.UserDefaultsKeys.email)
        userDefaults.set(user.avatarUrl, forKey: Constants.UserDefaultsKeys.avatarUrl)
        userDefaults.synchronize()
    }
    
    // MARK: - Helper Methods
    func getStoredValue(for key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func setStoredValue(_ value: String, for key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    func clearStoredValue(for key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
}

// MARK: - Authentication Extensions
extension AuthManager {
    func validateLoginForm(system: String, username: String, password: String, otp: String) -> String? {
        if system.isEmpty {
            return "Vui lòng chọn hệ thống"
        }
        
        if username.isEmpty {
            return "Vui lòng nhập tên đăng nhập"
        }
        
        if password.isEmpty {
            return "Vui lòng nhập mật khẩu"
        }
        
        if otp.isEmpty {
            return "Vui lòng nhập mã OTP"
        }
        
        if otp.count != 6 {
            return "Mã OTP phải có 6 chữ số"
        }
        
        return nil
    }
    
    func getAvailableSystems() -> [String] {
        // This would typically come from an API call
        // For now, return a default list
        return ["Hệ thống 1", "Hệ thống 2", "Hệ thống 3"]
    }
}
