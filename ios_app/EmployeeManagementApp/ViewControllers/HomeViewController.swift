import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var systemLabel: UILabel!
    
    @IBOutlet weak var attendanceCardView: UIView!
    @IBOutlet weak var clockInButton: UIButton!
    @IBOutlet weak var clockOutButton: UIButton!
    @IBOutlet weak var attendanceStatusLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    
    @IBOutlet weak var quickStatsView: UIView!
    @IBOutlet weak var todayHoursLabel: UILabel!
    @IBOutlet weak var monthlyHoursLabel: UILabel!
    @IBOutlet weak var unreadNotificationsLabel: UILabel!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let authManager = AuthManager.shared
    private let networkManager = NetworkManager.shared
    private var currentAttendance: Attendance?
    private var monthlyData: MonthlyData?
    private var unreadNotificationsCount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Trang chủ"
        navigationItem.rightBarButtonItems = [logoutButton, refreshButton]
        
        // Configure user info view
        userInfoView.layer.cornerRadius = 12
        userInfoView.layer.shadowColor = UIColor.black.cgColor
        userInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userInfoView.layer.shadowRadius = 4
        userInfoView.layer.shadowOpacity = 0.1
        
        // Configure avatar
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        // Configure attendance card
        attendanceCardView.layer.cornerRadius = 12
        attendanceCardView.layer.shadowColor = UIColor.black.cgColor
        attendanceCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        attendanceCardView.layer.shadowRadius = 4
        attendanceCardView.layer.shadowOpacity = 0.1
        
        // Configure buttons
        clockInButton.layer.cornerRadius = 8
        clockOutButton.layer.cornerRadius = 8
        clockOutButton.backgroundColor = UIColor.systemRed
        
        // Configure quick stats
        quickStatsView.layer.cornerRadius = 12
        quickStatsView.layer.shadowColor = UIColor.black.cgColor
        quickStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        quickStatsView.layer.shadowRadius = 4
        quickStatsView.layer.shadowOpacity = 0.1
        
        // Configure notification badge
        unreadNotificationsLabel.layer.cornerRadius = unreadNotificationsLabel.frame.width / 2
        unreadNotificationsLabel.clipsToBounds = true
        unreadNotificationsLabel.backgroundColor = UIColor.systemRed
        unreadNotificationsLabel.textColor = UIColor.white
        unreadNotificationsLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    private func loadUserData() {
        guard let user = authManager.currentUser else { return }
        
        welcomeLabel.text = "Xin chào, \(user.fullName)!"
        nameLabel.text = user.fullName
        positionLabel.text = user.position ?? "Chưa cập nhật"
        departmentLabel.text = user.department ?? "Chưa cập nhật"
        systemLabel.text = authManager.currentSystemName
        
        // Load avatar
        if let avatarUrl = user.avatarUrl, !avatarUrl.isEmpty {
            loadAvatar(from: avatarUrl)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    private func loadInitialData() {
        loadAttendanceStatus()
        loadMonthlyData()
        loadNotifications()
    }
    
    // MARK: - Data Loading
    private func refreshData() {
        loadAttendanceStatus()
        loadMonthlyData()
        loadNotifications()
    }
    
    private func loadAttendanceStatus() {
        // This would typically load current day attendance
        // For now, we'll simulate the data
        updateAttendanceUI(isClockedIn: false, workTime: "0h 0m")
    }
    
    private func loadMonthlyData() {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        networkManager.getMonthlyData(month: month, year: year) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.monthlyData = data
                        self?.updateMonthlyStats(data)
                    }
                case .failure(let error):
                    print("Error loading monthly data: \(error.message)")
                }
            }
        }
    }
    
    private func loadNotifications() {
        networkManager.getNotifications { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.unreadNotificationsCount = response.unreadCount
                        self?.updateNotificationsBadge()
                    }
                case .failure(let error):
                    print("Error loading notifications: \(error.message)")
                }
            }
        }
    }
    
    private func loadAvatar(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - UI Updates
    private func updateAttendanceUI(isClockedIn: Bool, workTime: String) {
        if isClockedIn {
            attendanceStatusLabel.text = "Đang làm việc"
            attendanceStatusLabel.textColor = .systemGreen
            clockInButton.isEnabled = false
            clockOutButton.isEnabled = true
        } else {
            attendanceStatusLabel.text = "Chưa chấm công"
            attendanceStatusLabel.textColor = .systemOrange
            clockInButton.isEnabled = true
            clockOutButton.isEnabled = false
        }
        
        workTimeLabel.text = "Thời gian làm việc: \(workTime)"
    }
    
    private func updateMonthlyStats(_ data: MonthlyData) {
        todayHoursLabel.text = "Hôm nay: \(data.totalHours)h"
        monthlyHoursLabel.text = "Tháng này: \(data.approvedHours)h"
    }
    
    private func updateNotificationsBadge() {
        if unreadNotificationsCount > 0 {
            unreadNotificationsLabel.isHidden = false
            unreadNotificationsLabel.text = "\(unreadNotificationsCount)"
        } else {
            unreadNotificationsLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    @IBAction func clockInButtonTapped(_ sender: UIButton) {
        performClockIn()
    }
    
    @IBAction func clockOutButtonTapped(_ sender: UIButton) {
        performClockOut()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        refreshData()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        showLogoutConfirmation()
    }
    
    // MARK: - Clock In/Out Logic
    private func performClockIn() {
        setLoading(true, for: clockInButton)
        
        networkManager.clockInOut(action: "clock_in") { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false, for: self?.clockInButton)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert(title: "Thành công", message: "Chấm công vào thành công!")
                        self?.updateAttendanceUI(isClockedIn: true, workTime: "0h 0m")
                    } else {
                        self?.showAlert(title: "Lỗi", message: response.message)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func performClockOut() {
        setLoading(true, for: clockOutButton)
        
        networkManager.clockInOut(action: "clock_out") { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false, for: self?.clockOutButton)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert(title: "Thành công", message: "Chấm công ra thành công!")
                        self?.updateAttendanceUI(isClockedIn: false, workTime: "8h 0m")
                    } else {
                        self?.showAlert(title: "Lỗi", message: response.message)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func setLoading(_ isLoading: Bool, for button: UIButton?) {
        guard let button = button else { return }
        
        if isLoading {
            button.isEnabled = false
            button.setTitle("Đang xử lý...", for: .normal)
        } else {
            button.isEnabled = true
            if button == clockInButton {
                button.setTitle("Chấm công vào", for: .normal)
            } else {
                button.setTitle("Chấm công ra", for: .normal)
            }
        }
    }
    
    // MARK: - Logout
    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Đăng xuất", message: "Bạn có chắc chắn muốn đăng xuất?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        authManager.logout { [weak self] in
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                let navigationController = UINavigationController(rootViewController: loginVC)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
