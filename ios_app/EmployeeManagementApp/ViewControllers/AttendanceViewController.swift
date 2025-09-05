import UIKit

class AttendanceViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private var attendances: [Attendance] = []
    private var filteredAttendances: [Attendance] = []
    private var currentFilter: AttendanceFilter = .all
    
    // MARK: - Enums
    enum AttendanceFilter: Int, CaseIterable {
        case all = 0
        case today = 1
        case thisWeek = 2
        case thisMonth = 3
        
        var title: String {
            switch self {
            case .all: return "Tất cả"
            case .today: return "Hôm nay"
            case .thisWeek: return "Tuần này"
            case .thisMonth: return "Tháng này"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAttendanceData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Chấm công"
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
        
        // Configure segmented control
        segmentedControl.removeAllSegments()
        for (index, filter) in AttendanceFilter.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: filter.title, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AttendanceTableViewCell.self, forCellReuseIdentifier: "AttendanceCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // Add pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    @objc private func refreshData() {
        loadAttendanceData()
    }
    
    private func loadAttendanceData() {
        setLoading(true)
        
        networkManager.getAttendanceHistory { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                self?.tableView.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let attendances):
                    self?.attendances = attendances
                    self?.applyFilter()
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func applyFilter() {
        let calendar = Calendar.current
        let now = Date()
        
        switch currentFilter {
        case .all:
            filteredAttendances = attendances
        case .today:
            filteredAttendances = attendances.filter { attendance in
                guard let date = DateFormatter.iso8601.date(from: attendance.date) else { return false }
                return calendar.isDate(date, inSameDayAs: now)
            }
        case .thisWeek:
            filteredAttendances = attendances.filter { attendance in
                guard let date = DateFormatter.iso8601.date(from: attendance.date) else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            filteredAttendances = attendances.filter { attendance in
                guard let date = DateFormatter.iso8601.date(from: attendance.date) else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            }
        }
        
        tableView.reloadData()
    }
    
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            refreshButton.isEnabled = false
            addButton.isEnabled = false
        } else {
            refreshButton.isEnabled = true
            addButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        currentFilter = AttendanceFilter(rawValue: sender.selectedSegmentIndex) ?? .all
        applyFilter()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        showClockInOutOptions()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        refreshData()
    }
    
    // MARK: - Clock In/Out Options
    private func showClockInOutOptions() {
        let alert = UIAlertController(title: "Chấm công", message: "Chọn hành động", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Chấm công vào", style: .default) { [weak self] _ in
            self?.performClockIn()
        })
        
        alert.addAction(UIAlertAction(title: "Chấm công ra", style: .default) { [weak self] _ in
            self?.performClockOut()
        })
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = addButton
        }
        
        present(alert, animated: true)
    }
    
    private func performClockIn() {
        setLoading(true)
        
        networkManager.clockInOut(action: "clock_in") { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert(title: "Thành công", message: "Chấm công vào thành công!")
                        self?.refreshData()
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
        setLoading(true)
        
        networkManager.clockInOut(action: "clock_out") { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert(title: "Thành công", message: "Chấm công ra thành công!")
                        self?.refreshData()
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
extension AttendanceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAttendances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceTableViewCell
        let attendance = filteredAttendances[indexPath.row]
        cell.configure(with: attendance)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AttendanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let attendance = filteredAttendances[indexPath.row]
        showAttendanceDetail(attendance)
    }
    
    private func showAttendanceDetail(_ attendance: Attendance) {
        let alert = UIAlertController(title: "Chi tiết chấm công", message: nil, preferredStyle: .alert)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var message = "Ngày: \(attendance.date)\n"
        
        if let timeIn = attendance.timeIn {
            message += "Vào: \(timeIn)\n"
        }
        
        if let timeOut = attendance.timeOut {
            message += "Ra: \(timeOut)\n"
        }
        
        if let hoursWorked = attendance.hoursWorked {
            message += "Giờ làm: \(String(format: "%.1f", hoursWorked))h\n"
        }
        
        message += "Trạng thái: \(attendance.status)"
        
        alert.message = message
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - Custom Table View Cell
class AttendanceTableViewCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    private let timeInLabel = UILabel()
    private let timeOutLabel = UILabel()
    private let hoursLabel = UILabel()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure labels
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        timeInLabel.font = UIFont.systemFont(ofSize: 14)
        timeOutLabel.font = UIFont.systemFont(ofSize: 14)
        hoursLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        
        timeInLabel.textColor = .systemGreen
        timeOutLabel.textColor = .systemRed
        hoursLabel.textColor = .systemBlue
        statusLabel.textColor = .systemGray
        
        // Add to content view
        [dateLabel, timeInLabel, timeOutLabel, hoursLabel, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeInLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            timeInLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            timeOutLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            timeOutLabel.leadingAnchor.constraint(equalTo: timeInLabel.trailingAnchor, constant: 16),
            
            hoursLabel.topAnchor.constraint(equalTo: timeInLabel.bottomAnchor, constant: 4),
            hoursLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            statusLabel.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with attendance: Attendance) {
        dateLabel.text = attendance.date
        
        if let timeIn = attendance.timeIn {
            timeInLabel.text = "Vào: \(timeIn)"
        } else {
            timeInLabel.text = "Vào: --:--"
        }
        
        if let timeOut = attendance.timeOut {
            timeOutLabel.text = "Ra: \(timeOut)"
        } else {
            timeOutLabel.text = "Ra: --:--"
        }
        
        if let hours = attendance.hoursWorked {
            hoursLabel.text = "Giờ làm: \(String(format: "%.1f", hours))h"
        } else {
            hoursLabel.text = "Giờ làm: --h"
        }
        
        statusLabel.text = "Trạng thái: \(attendance.status)"
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
