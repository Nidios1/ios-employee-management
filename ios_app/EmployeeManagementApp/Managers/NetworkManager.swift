import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        self.baseURL = Constants.baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError(message: "URL không hợp lệ")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add parameters
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                completion(.failure(APIError(message: "Lỗi mã hóa dữ liệu")))
                return
            }
        }
        
        // Add form data for POST requests
        if method == .POST && parameters != nil {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if let formData = createFormData(from: parameters!) {
                request.httpBody = formData
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError(message: "Lỗi kết nối: \(error.localizedDescription)")))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError(message: "Phản hồi không hợp lệ")))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError(message: "Không có dữ liệu trả về")))
                    return
                }
                
                // Log response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("API Response: \(responseString)")
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(APIError(message: "Lỗi giải mã dữ liệu: \(error.localizedDescription)")))
                }
            }
        }.resume()
    }
    
    private func createFormData(from parameters: [String: Any]) -> Data? {
        var components = URLComponents()
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        return components.query?.data(using: .utf8)
    }
    
    // MARK: - Authentication
    func login(system: String, username: String, password: String, otp: String, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "system": system,
            "username": username,
            "password": password,
            "otp": otp
        ]
        
        request(
            endpoint: Constants.Endpoints.login,
            method: .POST,
            parameters: parameters,
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Attendance
    func clockInOut(action: String, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil, completion: @escaping (Result<ClockInOutResponse, APIError>) -> Void) {
        var parameters: [String: Any] = ["action": action]
        
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let address = address {
            parameters["address"] = address
        }
        
        request(
            endpoint: Constants.Endpoints.clockInOut,
            method: .POST,
            parameters: parameters,
            responseType: ClockInOutResponse.self,
            completion: completion
        )
    }
    
    func getAttendanceHistory(completion: @escaping (Result<[Attendance], APIError>) -> Void) {
        request(
            endpoint: Constants.Endpoints.attendance,
            method: .GET,
            responseType: [Attendance].self,
            completion: completion
        )
    }
    
    // MARK: - Salary
    func getMonthlyData(month: Int, year: Int, completion: @escaping (Result<SalaryResponse, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "month": month,
            "year": year
        ]
        
        request(
            endpoint: Constants.Endpoints.monthlyData,
            method: .GET,
            parameters: parameters,
            responseType: SalaryResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Notifications
    func getNotifications(completion: @escaping (Result<NotificationResponse, APIError>) -> Void) {
        let parameters: [String: Any] = ["action": "get_notifications"]
        
        request(
            endpoint: Constants.Endpoints.notifications,
            method: .GET,
            parameters: parameters,
            responseType: NotificationResponse.self,
            completion: completion
        )
    }
    
    func markNotificationAsRead(notificationId: Int, completion: @escaping (Result<APIResponse<[String: String]>, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "action": "mark_read",
            "notification_id": notificationId
        ]
        
        request(
            endpoint: Constants.Endpoints.notifications,
            method: .POST,
            parameters: parameters,
            responseType: APIResponse<[String: String]>.self,
            completion: completion
        )
    }
    
    func markAllNotificationsAsRead(completion: @escaping (Result<APIResponse<[String: String]>, APIError>) -> Void) {
        let parameters: [String: Any] = ["action": "mark_all_read"]
        
        request(
            endpoint: Constants.Endpoints.notifications,
            method: .POST,
            parameters: parameters,
            responseType: APIResponse<[String: String]>.self,
            completion: completion
        )
    }
    
    // MARK: - Chat
    func sendChatMessage(question: String, completion: @escaping (Result<ChatResponse, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "action": "ask_ai",
            "question": question
        ]
        
        request(
            endpoint: Constants.Endpoints.chat,
            method: .POST,
            parameters: parameters,
            responseType: ChatResponse.self,
            completion: completion
        )
    }
    
    func getChatHistory(completion: @escaping (Result<ChatHistoryResponse, APIError>) -> Void) {
        let parameters: [String: Any] = ["action": "get_history"]
        
        request(
            endpoint: Constants.Endpoints.chat,
            method: .GET,
            parameters: parameters,
            responseType: ChatHistoryResponse.self,
            completion: completion
        )
    }
    
    func saveChatMessage(question: String, answer: String, completion: @escaping (Result<APIResponse<[String: String]>, APIError>) -> Void) {
        let parameters: [String: Any] = [
            "action": "save_history",
            "question": question,
            "answer": answer
        ]
        
        request(
            endpoint: Constants.Endpoints.chat,
            method: .POST,
            parameters: parameters,
            responseType: APIResponse<[String: String]>.self,
            completion: completion
        )
    }
    
    // MARK: - Profile
    func getEmployeeDetail(employeeId: Int, completion: @escaping (Result<APIResponse<User>, APIError>) -> Void) {
        let parameters: [String: Any] = ["id": employeeId]
        
        request(
            endpoint: Constants.Endpoints.employeeDetail,
            method: .GET,
            parameters: parameters,
            responseType: APIResponse<User>.self,
            completion: completion
        )
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Error Handling
extension NetworkManager {
    func handleNetworkError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.message
        } else {
            return "Lỗi không xác định: \(error.localizedDescription)"
        }
    }
}
