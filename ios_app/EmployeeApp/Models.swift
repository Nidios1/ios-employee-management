import Foundation

// MARK: - User Model
struct User: Codable {
    let id: String
    let username: String
    let fullName: String
    let email: String
    let department: String
    let position: String
}

// MARK: - Attendance Model
struct Attendance: Codable {
    let id: String
    let userId: String
    let date: String
    let clockIn: String?
    let clockOut: String?
    let status: String
}

// MARK: - Salary Model
struct Salary: Codable {
    let id: String
    let userId: String
    let month: String
    let year: String
    let basicSalary: Double
    let allowances: Double
    let deductions: Double
    let netSalary: Double
}

// MARK: - Notification Model
struct Notification: Codable {
    let id: String
    let title: String
    let message: String
    let date: String
    let isRead: Bool
}

// MARK: - Chat Model
struct Chat: Codable {
    let id: String
    let message: String
    let timestamp: String
    let isFromUser: Bool
}

// MARK: - API Response Models
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let user: User?
    let token: String?
}

struct AttendanceResponse: Codable {
    let success: Bool
    let message: String
    let attendance: Attendance?
}

struct SalaryResponse: Codable {
    let success: Bool
    let message: String
    let salary: Salary?
}

struct NotificationsResponse: Codable {
    let success: Bool
    let message: String
    let notifications: [Notification]?
}

struct ChatResponse: Codable {
    let success: Bool
    let message: String
    let response: String?
}

// MARK: - Constants
struct Constants {
    static let baseURL = "http://localhost/employee_management"
    static let loginEndpoint = "/api/login_process.php"
    static let clockInEndpoint = "/api/clock_in_out.php"
    static let salaryEndpoint = "/api/api_monthly_data.php"
    static let notificationsEndpoint = "/api/api_notifications.php"
    static let chatEndpoint = "/api/api_chat.php"
}
