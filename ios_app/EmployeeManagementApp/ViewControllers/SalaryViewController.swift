import UIKit

class SalaryViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var currentSalaryCard: UIView!
    @IBOutlet weak var currentSalaryLabel: UILabel!
    @IBOutlet weak var salaryDateLabel: UILabel!
    
    @IBOutlet weak var monthlyStatsCard: UIView!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var standardHoursLabel: UILabel!
    @IBOutlet weak var workedHoursLabel: UILabel!
    @IBOutlet weak var approvedHoursLabel: UILabel!
    @IBOutlet weak var workingDaysLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let calendar = Calendar.current
    private var monthlyData: MonthlyData?
    private var currentSalary: Double = 0
    
    private let months = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
                         "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"]
    private var years: [Int] = []
    
    private var selectedMonth: Int {
        return monthPickerView.selectedRow(inComponent: 0) + 1
    }
    
    private var selectedYear: Int {
        return years[yearPickerView.selectedRow(inComponent: 0)]
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Lương"
        navigationItem.rightBarButtonItem = refreshButton
        
        // Configure cards
        [currentSalaryCard, monthlyStatsCard].forEach { card in
            card.layer.cornerRadius = 12
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.layer.shadowRadius = 4
            card.layer.shadowOpacity = 0.1
        }
        
        // Configure progress view
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        // Configure labels
        currentSalaryLabel.font = UIFont.boldSystemFont(ofSize: 24)
        currentSalaryLabel.textColor = .systemGreen
        
        monthYearLabel.font = UIFont.boldSystemFont(ofSize: 18)
        monthYearLabel.textColor = .label
    }
    
    private func setupPickers() {
        // Setup month picker
        monthPickerView.delegate = self
        monthPickerView.dataSource = self
        
        // Setup year picker
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        // Generate years (current year ± 2)
        let currentYear = calendar.component(.year, from: Date())
        years = Array((currentYear - 2)...(currentYear + 2))
        
        // Set default selection to current month/year
        let currentMonth = calendar.component(.month, from: Date())
        monthPickerView.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        
        let currentYearIndex = years.firstIndex(of: currentYear) ?? 0
        yearPickerView.selectRow(currentYearIndex, inComponent: 0, animated: false)
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        loadCurrentSalary()
        loadMonthlyData()
    }
    
    @objc private func refreshData() {
        loadCurrentSalary()
        loadMonthlyData()
    }
    
    private func loadCurrentSalary() {
        // This would typically load from an API
        // For now, we'll use a default value
        currentSalary = 15000000 // 15,000,000 VND
        updateCurrentSalaryUI()
    }
    
    private func loadMonthlyData() {
        setLoading(true)
        
        networkManager.getMonthlyData(month: selectedMonth, year: selectedYear) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.monthlyData = data
                        self?.updateMonthlyStatsUI(data)
                    } else {
                        self?.showAlert(title: "Lỗi", message: response.message)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        refreshButton.isEnabled = !isLoading
    }
    
    // MARK: - UI Updates
    private func updateCurrentSalaryUI() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.locale = Locale(identifier: "vi_VN")
        
        currentSalaryLabel.text = formatter.string(from: NSNumber(value: currentSalary))
        salaryDateLabel.text = "Cập nhật: \(DateFormatter.shortDate.string(from: Date()))"
    }
    
    private func updateMonthlyStatsUI(_ data: MonthlyData) {
        monthYearLabel.text = "\(data.monthName) \(data.year)"
        standardHoursLabel.text = "Giờ chuẩn: \(data.standardHours)h"
        workedHoursLabel.text = "Đã làm: \(data.totalHours)h"
        approvedHoursLabel.text = "Đã duyệt: \(data.approvedHours)h"
        workingDaysLabel.text = "Ngày làm: \(data.workingDays) ngày"
        
        // Update progress
        let progress = Float(data.approvedHours) / Float(data.standardHours)
        progressView.setProgress(progress, animated: true)
        
        // Update progress color based on completion
        if progress >= 1.0 {
            progressView.progressTintColor = .systemGreen
        } else if progress >= 0.8 {
            progressView.progressTintColor = .systemOrange
        } else {
            progressView.progressTintColor = .systemRed
        }
    }
    
    // MARK: - Actions
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        refreshData()
    }
    
    @IBAction func monthPickerChanged(_ sender: UIPickerView) {
        loadMonthlyData()
    }
    
    @IBAction func yearPickerChanged(_ sender: UIPickerView) {
        loadMonthlyData()
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension SalaryViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == monthPickerView {
            return months.count
        } else {
            return years.count
        }
    }
}

// MARK: - UIPickerViewDelegate
extension SalaryViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == monthPickerView {
            return months[row]
        } else {
            return "\(years[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadMonthlyData()
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter
    }()
}
