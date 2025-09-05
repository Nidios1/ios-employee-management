import Foundation

// MARK: - User Models
struct User: Codable {
    let id: Int
    let username: String
    let fullName: String
    let email: String
    let phone: String?
    let position: String?
    let department: String?
    let employeeId: String?
    let avatarUrl: String?
    let isAdmin: Bool
    let systemId: Int
    let lastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, phone, position, department
        case fullName = "full_name"
        case employeeId = "employee_id"
        case avatarUrl = "avatar_url"
        case isAdmin = "is_admin"
        case systemId = "system_id"
        case lastLogin = "last_login"
    }
}

struct System: Codable {
    let id: Int
    let name: String
    let description: String?
    let isActive: Bool
    let isMaintenance: Bool
    let maintenanceMessage: String?
    let maintenanceUntil: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case isActive = "is_active"
        case isMaintenance = "is_maintenance"
        case maintenanceMessage = "maintenance_message"
        case maintenanceUntil = "maintenance_until"
    }
}

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let system: String
    let username: String
    let password: String
    let otp: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let user: User?
    let system: System?
}

// MARK: - Attendance Models
struct Attendance: Codable {
    let id: Int
    let userId: Int
    let date: String
    let timeIn: String?
    let timeOut: String?
    let hoursWorked: Double?
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, status
        case userId = "user_id"
        case timeIn = "time_in"
        case timeOut = "time_out"
        case hoursWorked = "hours_worked"
        case createdAt = "created_at"
    }
}

struct ClockInOutRequest: Codable {
    let action: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
}

struct ClockInOutResponse: Codable {
    let success: Bool
    let message: String
    let data: AttendanceData?
}

struct AttendanceData: Codable {
    let timeIn: String?
    let timeOut: String?
    let status: String
    let hoursWorked: Double?
}

// MARK: - Salary Models
struct Salary: Codable {
    let id: Int
    let userId: Int
    let salary: Double
    let salaryDate: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, salary
        case userId = "user_id"
        case salaryDate = "salary_date"
        case createdAt = "created_at"
    }
}

struct MonthlyData: Codable {
    let month: Int
    let monthName: String
    let year: Int
    let standardHours: Int
    let approvedHours: Int
    let workingDays: Int
    let totalHours: Int
    
    enum CodingKeys: String, CodingKey {
        case month, year, workingDays, totalHours
        case monthName = "month_name"
        case standardHours = "standard_hours"
        case approvedHours = "approved_hours"
    }
}

struct SalaryResponse: Codable {
    let success: Bool
    let message: String
    let data: MonthlyData?
}

// MARK: - Notification Models
struct Notification: Codable {
    let id: Int
    let title: String
    let message: String
    let type: String
    let isRead: Bool
    let createdAt: String
    let timeAgo: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, type, createdAt
        case isRead = "is_read"
        case timeAgo = "time_ago"
    }
}

struct NotificationResponse: Codable {
    let success: Bool
    let unreadCount: Int
    let notifications: [Notification]
    
    enum CodingKeys: String, CodingKey {
        case success, notifications
        case unreadCount = "unread_count"
    }
}

// MARK: - Chat Models
struct ChatMessage: Codable {
    let question: String
    let answer: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case question, answer
        case createdAt = "created_at"
    }
}

struct ChatHistoryResponse: Codable {
    let success: Bool
    let messages: [ChatMessage]
}

struct ChatRequest: Codable {
    let action: String
    let question: String?
}

struct ChatResponse: Codable {
    let success: Bool
    let answer: String?
    let message: String?
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
}

// MARK: - Error Models
struct APIError: Error {
    let message: String
    let code: Int?
    
    init(message: String, code: Int? = nil) {
        self.message = message
        self.code = code
    }
}

// MARK: - Constants
struct Constants {
    static let baseURL = "http://localhost" // Thay đổi theo server của bạn
    static let apiVersion = "v1"
    
    struct Endpoints {
        static let login = "/login_process.php"
        static let logout = "/logout.php"
        static let clockInOut = "/clock_in_out.php"
        static let attendance = "/attendance.php"
        static let salary = "/my_salary.php"
        static let monthlyData = "/api_monthly_data.php"
        static let notifications = "/api_notifications.php"
        static let chat = "/api_chat.php"
        static let employeeDetail = "/api_employee_detail.php"
        static let profile = "/profile.php"
    }
    
    struct UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let userId = "userId"
        static let username = "username"
        static let fullName = "fullName"
        static let email = "email"
        static let systemId = "systemId"
        static let systemName = "systemName"
        static let avatarUrl = "avatarUrl"
        static let isAdmin = "isAdmin"
        static let lastLogin = "lastLogin"
    }
}
