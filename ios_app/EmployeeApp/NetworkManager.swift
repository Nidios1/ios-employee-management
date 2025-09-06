import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Login
    func login(username: String, password: String, totpCode: String) -> AnyPublisher<LoginResponse, Error> {
        let url = URL(string: "\(Constants.baseURL)\(Constants.loginEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "username=\(username)&password=\(password)&totp_code=\(totpCode)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Clock In/Out
    func clockInOut(userId: String, action: String) -> AnyPublisher<AttendanceResponse, Error> {
        let url = URL(string: "\(Constants.baseURL)\(Constants.clockInEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "user_id=\(userId)&action=\(action)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AttendanceResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Salary
    func getSalary(userId: String, month: String, year: String) -> AnyPublisher<SalaryResponse, Error> {
        let url = URL(string: "\(Constants.baseURL)\(Constants.salaryEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "user_id=\(userId)&month=\(month)&year=\(year)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SalaryResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Get Notifications
    func getNotifications(userId: String) -> AnyPublisher<NotificationsResponse, Error> {
        let url = URL(string: "\(Constants.baseURL)\(Constants.notificationsEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "user_id=\(userId)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: NotificationsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Chat with AI
    func sendChatMessage(userId: String, message: String) -> AnyPublisher<ChatResponse, Error> {
        let url = URL(string: "\(Constants.baseURL)\(Constants.chatEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "user_id=\(userId)&message=\(message)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
