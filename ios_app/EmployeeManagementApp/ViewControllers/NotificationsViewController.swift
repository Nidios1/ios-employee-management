import UIKit

class NotificationsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var markAllReadButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private var notifications: [Notification] = []
    private var filteredNotifications: [Notification] = []
    private var currentFilter: NotificationFilter = .all
    private var unreadCount = 0
    
    // MARK: - Enums
    enum NotificationFilter: Int, CaseIterable {
        case all = 0
        case unread = 1
        case read = 2
        
        var title: String {
            switch self {
            case .all: return "Tất cả"
            case .unread: return "Chưa đọc"
            case .read: return "Đã đọc"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Thông báo"
        navigationItem.rightBarButtonItems = [markAllReadButton, refreshButton]
        
        // Configure segmented control
        segmentedControl.removeAllSegments()
        for (index, filter) in NotificationFilter.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: filter.title, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // Add pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Configure empty state
        setupEmptyState()
    }
    
    private func setupEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Không có thông báo nào"
        emptyLabel.textColor = .systemGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        emptyLabel.isHidden = true
        emptyLabel.tag = 999 // For easy access
    }
    
    // MARK: - Data Loading
    @objc private func refreshData() {
        loadNotifications()
    }
    
    private func loadNotifications() {
        setLoading(true)
        
        networkManager.getNotifications { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                self?.tableView.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.notifications = response.notifications
                        self?.unreadCount = response.unreadCount
                        self?.applyFilter()
                        self?.updateUI()
                    } else {
                        self?.showAlert(title: "Lỗi", message: "Không thể tải thông báo")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func applyFilter() {
        switch currentFilter {
        case .all:
            filteredNotifications = notifications
        case .unread:
            filteredNotifications = notifications.filter { !$0.isRead }
        case .read:
            filteredNotifications = notifications.filter { $0.isRead }
        }
        
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let emptyLabel = view.viewWithTag(999) as? UILabel
        emptyLabel?.isHidden = !filteredNotifications.isEmpty
    }
    
    private func updateUI() {
        // Update segmented control with unread count
        let unreadTitle = "Chưa đọc (\(unreadCount))"
        segmentedControl.setTitle(unreadTitle, forSegmentAt: NotificationFilter.unread.rawValue)
        
        // Update mark all read button
        markAllReadButton.isEnabled = unreadCount > 0
    }
    
    private func setLoading(_ isLoading: Bool) {
        refreshButton.isEnabled = !isLoading
        markAllReadButton.isEnabled = !isLoading && unreadCount > 0
    }
    
    // MARK: - Actions
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        currentFilter = NotificationFilter(rawValue: sender.selectedSegmentIndex) ?? .all
        applyFilter()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        refreshData()
    }
    
    @IBAction func markAllReadButtonTapped(_ sender: UIBarButtonItem) {
        markAllAsRead()
    }
    
    // MARK: - Notification Actions
    private func markAsRead(_ notification: Notification) {
        guard !notification.isRead else { return }
        
        networkManager.markNotificationAsRead(notificationId: notification.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Update local data
                        if let index = self?.notifications.firstIndex(where: { $0.id == notification.id }) {
                            self?.notifications[index] = Notification(
                                id: notification.id,
                                title: notification.title,
                                message: notification.message,
                                type: notification.type,
                                isRead: true,
                                createdAt: notification.createdAt,
                                timeAgo: notification.timeAgo
                            )
                        }
                        
                        self?.unreadCount = max(0, self?.unreadCount ?? 0 - 1)
                        self?.applyFilter()
                        self?.updateUI()
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func markAllAsRead() {
        let alert = UIAlertController(title: "Đánh dấu tất cả", message: "Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default) { [weak self] _ in
            self?.performMarkAllAsRead()
        })
        
        present(alert, animated: true)
    }
    
    private func performMarkAllAsRead() {
        setLoading(true)
        
        networkManager.markAllNotificationsAsRead { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        // Update local data
                        self?.notifications = self?.notifications.map { notification in
                            Notification(
                                id: notification.id,
                                title: notification.title,
                                message: notification.message,
                                type: notification.type,
                                isRead: true,
                                createdAt: notification.createdAt,
                                timeAgo: notification.timeAgo
                            )
                        } ?? []
                        
                        self?.unreadCount = 0
                        self?.applyFilter()
                        self?.updateUI()
                        
                        self?.showAlert(title: "Thành công", message: "Đã đánh dấu tất cả thông báo là đã đọc")
                    } else {
                        self?.showAlert(title: "Lỗi", message: response.message)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
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

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        let notification = filteredNotifications[indexPath.row]
        cell.configure(with: notification)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = filteredNotifications[indexPath.row]
        
        // Mark as read if not already read
        if !notification.isRead {
            markAsRead(notification)
        }
        
        // Show notification detail
        showNotificationDetail(notification)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = filteredNotifications[indexPath.row]
        
        var actions: [UIContextualAction] = []
        
        if !notification.isRead {
            let markReadAction = UIContextualAction(style: .normal, title: "Đã đọc") { [weak self] _, _, completion in
                self?.markAsRead(notification)
                completion(true)
            }
            markReadAction.backgroundColor = .systemBlue
            actions.append(markReadAction)
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            self?.deleteNotification(notification)
            completion(true)
        }
        actions.append(deleteAction)
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    private func showNotificationDetail(_ notification: Notification) {
        let alert = UIAlertController(title: notification.title, message: notification.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func deleteNotification(_ notification: Notification) {
        // Implement delete functionality
        showAlert(title: "Xóa thông báo", message: "Tính năng xóa thông báo sẽ được thêm trong phiên bản sau")
    }
}

// MARK: - Custom Table View Cell
class NotificationTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let typeIndicator = UIView()
    private let unreadIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .systemGray
        messageLabel.numberOfLines = 3
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray2
        
        // Configure indicators
        typeIndicator.layer.cornerRadius = 4
        unreadIndicator.layer.cornerRadius = 4
        unreadIndicator.backgroundColor = .systemBlue
        
        // Add to content view
        [titleLabel, messageLabel, timeLabel, typeIndicator, unreadIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            typeIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            typeIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            typeIndicator.widthAnchor.constraint(equalToConstant: 8),
            typeIndicator.heightAnchor.constraint(equalToConstant: 8),
            
            unreadIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unreadIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: typeIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: unreadIndicator.leadingAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: typeIndicator.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: unreadIndicator.leadingAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: typeIndicator.trailingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: unreadIndicator.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with notification: Notification) {
        titleLabel.text = notification.title
        messageLabel.text = notification.message
        timeLabel.text = notification.timeAgo ?? notification.createdAt
        
        // Configure type indicator color
        switch notification.type {
        case "success":
            typeIndicator.backgroundColor = .systemGreen
        case "warning":
            typeIndicator.backgroundColor = .systemOrange
        case "error":
            typeIndicator.backgroundColor = .systemRed
        default:
            typeIndicator.backgroundColor = .systemBlue
        }
        
        // Show/hide unread indicator
        unreadIndicator.isHidden = notification.isRead
        
        // Configure text color based on read status
        if notification.isRead {
            titleLabel.textColor = .systemGray
            messageLabel.textColor = .systemGray2
        } else {
            titleLabel.textColor = .label
            messageLabel.textColor = .systemGray
        }
    }
}
