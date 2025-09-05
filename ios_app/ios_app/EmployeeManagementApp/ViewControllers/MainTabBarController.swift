import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthentication()
    }
    
    // MARK: - Setup
    private func setupTabBar() {
        // Configure tab bar appearance
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.systemGray
        tabBar.backgroundColor = UIColor.systemBackground
        
        // Add shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = 0.1
    }
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Home
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Trang chủ",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Attendance
        let attendanceVC = storyboard.instantiateViewController(withIdentifier: "AttendanceViewController")
        let attendanceNav = UINavigationController(rootViewController: attendanceVC)
        attendanceNav.tabBarItem = UITabBarItem(
            title: "Chấm công",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )
        
        // Salary
        let salaryVC = storyboard.instantiateViewController(withIdentifier: "SalaryViewController")
        let salaryNav = UINavigationController(rootViewController: salaryVC)
        salaryNav.tabBarItem = UITabBarItem(
            title: "Lương",
            image: UIImage(systemName: "dollarsign.circle"),
            selectedImage: UIImage(systemName: "dollarsign.circle.fill")
        )
        
        // Notifications
        let notificationsVC = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController")
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        notificationsNav.tabBarItem = UITabBarItem(
            title: "Thông báo",
            image: UIImage(systemName: "bell"),
            selectedImage: UIImage(systemName: "bell.fill")
        )
        
        // Chat
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        let chatNav = UINavigationController(rootViewController: chatVC)
        chatNav.tabBarItem = UITabBarItem(
            title: "Chat",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )
        
        // Profile
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Hồ sơ",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // Set view controllers
        viewControllers = [
            homeNav,
            attendanceNav,
            salaryNav,
            notificationsNav,
            chatNav,
            profileNav
        ]
        
        // Set default selected tab
        selectedIndex = 0
    }
    
    private func checkAuthentication() {
        if !AuthManager.shared.isLoggedIn {
            showLoginScreen()
        }
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    // MARK: - Tab Bar Delegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Update badge if needed
        updateNotificationBadge()
    }
    
    private func updateNotificationBadge() {
        // This would typically update notification badge
        // Implementation depends on your notification system
    }
}

// MARK: - Extensions
extension MainTabBarController {
    
    func showNotificationBadge(on tabIndex: Int, count: Int) {
        guard tabIndex < tabBar.items?.count ?? 0 else { return }
        
        let tabBarItem = tabBar.items?[tabIndex]
        
        if count > 0 {
            tabBarItem?.badgeValue = "\(count)"
            tabBarItem?.badgeColor = UIColor.systemRed
        } else {
            tabBarItem?.badgeValue = nil
        }
    }
    
    func hideNotificationBadge(on tabIndex: Int) {
        showNotificationBadge(on: tabIndex, count: 0)
    }
    
    func updateAllBadges() {
        // Update all tab badges based on current data
        // This would be called when data changes
    }
}
