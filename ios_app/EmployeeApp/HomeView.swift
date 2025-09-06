import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var networkManager = NetworkManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Trang chủ")
                }
                .tag(0)
            
            // Attendance Tab
            AttendanceView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Chấm công")
                }
                .tag(1)
            
            // Salary Tab
            SalaryView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Lương")
                }
                .tag(2)
            
            // Notifications Tab
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Thông báo")
                }
                .tag(3)
            
            // Chat Tab
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat AI")
                }
                .tag(4)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Hồ sơ")
                }
                .tag(5)
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Chào mừng, \(authManager.currentUser?.fullName ?? "User")!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Hệ thống quản lý nhân viên")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    DashboardCard(
                        title: "Chấm công",
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    DashboardCard(
                        title: "Xem lương",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    DashboardCard(
                        title: "Thông báo",
                        icon: "bell.fill",
                        color: .orange
                    )
                    
                    DashboardCard(
                        title: "Chat AI",
                        icon: "message.fill",
                        color: .purple
                    )
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Trang chủ")
        }
    }
}

struct DashboardCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Attendance View
struct AttendanceView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var isClockedIn = false
    @State private var clockInTime = ""
    @State private var clockOutTime = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Chấm công")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 15) {
                    Text("Trạng thái: \(isClockedIn ? "Đã chấm công vào" : "Chưa chấm công")")
                        .font(.headline)
                        .foregroundColor(isClockedIn ? .green : .red)
                    
                    if isClockedIn {
                        Text("Giờ vào: \(clockInTime)")
                            .font(.subheadline)
                    }
                    
                    Button(action: clockInOut) {
                        Text(isClockedIn ? "Chấm công ra" : "Chấm công vào")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isClockedIn ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Chấm công")
        }
    }
    
    private func clockInOut() {
        guard let userId = authManager.currentUser?.id else { return }
        
        let action = isClockedIn ? "clock_out" : "clock_in"
        
        NetworkManager.shared.clockInOut(userId: userId, action: action)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    if response.success {
                        isClockedIn.toggle()
                        if isClockedIn {
                            clockInTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                        } else {
                            clockOutTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

// MARK: - Salary View
struct SalaryView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var salary: Salary?
    @State private var selectedMonth = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Lương tháng")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                DatePicker("Chọn tháng", selection: $selectedMonth, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                
                if let salary = salary {
                    VStack(spacing: 10) {
                        Text("Lương cơ bản: \(Int(salary.basicSalary).formatted()) VNĐ")
                        Text("Phụ cấp: \(Int(salary.allowances).formatted()) VNĐ")
                        Text("Khấu trừ: \(Int(salary.deductions).formatted()) VNĐ")
                        Text("Lương thực lĩnh: \(Int(salary.netSalary).formatted()) VNĐ")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button("Xem lương") {
                    loadSalary()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Lương")
        }
    }
    
    private func loadSalary() {
        guard let userId = authManager.currentUser?.id else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        let month = formatter.string(from: selectedMonth)
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: selectedMonth)
        
        NetworkManager.shared.getSalary(userId: userId, month: month, year: year)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    if response.success {
                        salary = response.salary
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

// MARK: - Notifications View
struct NotificationsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var notifications: [Notification] = []
    
    var body: some View {
        NavigationView {
            List(notifications, id: \.id) { notification in
                VStack(alignment: .leading, spacing: 5) {
                    Text(notification.title)
                        .font(.headline)
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(notification.date)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Thông báo")
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private func loadNotifications() {
        guard let userId = authManager.currentUser?.id else { return }
        
        NetworkManager.shared.getNotifications(userId: userId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    if response.success {
                        notifications = response.notifications ?? []
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

// MARK: - Chat View
struct ChatView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var message = ""
    @State private var chatMessages: [Chat] = []
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatMessages, id: \.id) { chat in
                            HStack {
                                if chat.isFromUser {
                                    Spacer()
                                    Text(chat.message)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Text(chat.message)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("Nhập tin nhắn...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Gửi") {
                        sendMessage()
                    }
                    .disabled(message.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Chat AI")
        }
    }
    
    private func sendMessage() {
        guard let userId = authManager.currentUser?.id, !message.isEmpty else { return }
        
        let userMessage = Chat(
            id: UUID().uuidString,
            message: message,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
            isFromUser: true
        )
        chatMessages.append(userMessage)
        
        let currentMessage = message
        message = ""
        
        NetworkManager.shared.sendChatMessage(userId: userId, message: currentMessage)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    if response.success, let aiResponse = response.response {
                        let aiMessage = Chat(
                            id: UUID().uuidString,
                            message: aiResponse,
                            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
                            isFromUser: false
                        )
                        chatMessages.append(aiMessage)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 15) {
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Phòng ban: \(user.department)")
                            .font(.subheadline)
                        
                        Text("Chức vụ: \(user.position)")
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button("Đăng xuất") {
                    authManager.logout()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Hồ sơ")
        }
    }
}

#Preview {
    HomeView()
}
