import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var authToken: String?
    
    private init() {
        // Load saved auth state
        loadAuthState()
    }
    
    // MARK: - Login
    func login(username: String, password: String, totpCode: String) -> AnyPublisher<Bool, Error> {
        NetworkManager.shared.login(username: username, password: password, totpCode: totpCode)
            .map { [weak self] response in
                if response.success {
                    self?.isLoggedIn = true
                    self?.currentUser = response.user
                    self?.authToken = response.token
                    self?.saveAuthState()
                    return true
                } else {
                    return false
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Logout
    func logout() {
        isLoggedIn = false
        currentUser = nil
        authToken = nil
        clearAuthState()
    }
    
    // MARK: - Save/Load Auth State
    private func saveAuthState() {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        if let user = currentUser {
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
        }
        if let token = authToken {
            UserDefaults.standard.set(token, forKey: "authToken")
        }
    }
    
    private func loadAuthState() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        authToken = UserDefaults.standard.string(forKey: "authToken")
    }
    
    private func clearAuthState() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}
