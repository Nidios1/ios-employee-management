import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var systemTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var systemPickerView: UIPickerView!
    @IBOutlet weak var totpTimeLabel: UILabel!
    @IBOutlet weak var totpProgressView: UIProgressView!
    
    // MARK: - Properties
    private let authManager = AuthManager.shared
    private let totpManager = TOTPManager.shared
    private var availableSystems: [String] = []
    private var timer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickerView()
        startTOTPTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure text fields
        systemTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        otpTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        otpTextField.keyboardType = .numberPad
        
        // Configure button
        loginButton.layer.cornerRadius = 8
        loginButton.backgroundColor = UIColor.systemBlue
        
        // Configure activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Load available systems
        availableSystems = authManager.getAvailableSystems()
        
        // Setup TOTP UI
        totpTimeLabel.text = "30s"
        totpProgressView.progress = 0.0
    }
    
    private func setupPickerView() {
        systemPickerView.delegate = self
        systemPickerView.dataSource = self
        systemPickerView.isHidden = true
        
        // Add toolbar to system text field
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        systemTextField.inputView = systemPickerView
        systemTextField.inputAccessoryView = toolbar
    }
    
    private func startTOTPTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTOTPDisplay()
        }
    }
    
    private func updateTOTPDisplay() {
        let timeRemaining = totpManager.getTimeRemaining()
        totpTimeLabel.text = totpManager.formatTimeRemaining(timeRemaining)
        totpProgressView.progress = totpManager.getProgressPercentage()
        
        // Change color based on time remaining
        if timeRemaining <= 5 {
            totpTimeLabel.textColor = .systemRed
            totpProgressView.progressTintColor = .systemRed
        } else if timeRemaining <= 10 {
            totpTimeLabel.textColor = .systemOrange
            totpProgressView.progressTintColor = .systemOrange
        } else {
            totpTimeLabel.textColor = .systemBlue
            totpProgressView.progressTintColor = .systemBlue
        }
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        performLogin()
    }
    
    @IBAction func systemTextFieldTapped(_ sender: UITextField) {
        systemPickerView.isHidden = false
    }
    
    @objc private func donePicker() {
        let selectedRow = systemPickerView.selectedRow(inComponent: 0)
        if selectedRow >= 0 && selectedRow < availableSystems.count {
            systemTextField.text = availableSystems[selectedRow]
        }
        systemTextField.resignFirstResponder()
        systemPickerView.isHidden = true
    }
    
    @objc private func cancelPicker() {
        systemTextField.resignFirstResponder()
        systemPickerView.isHidden = true
    }
    
    // MARK: - Login Logic
    private func performLogin() {
        guard let system = systemTextField.text,
              let username = usernameTextField.text,
              let password = passwordTextField.text,
              let otp = otpTextField.text else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập đầy đủ thông tin")
            return
        }
        
        // Validate form
        if let errorMessage = authManager.validateLoginForm(system: system, username: username, password: password, otp: otp) {
            showAlert(title: "Lỗi", message: errorMessage)
            return
        }
        
        // Show loading
        setLoading(true)
        
        // Perform login
        authManager.login(system: system, username: username, password: password, otp: otp) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success:
                    self?.navigateToMainInterface()
                case .failure(let error):
                    self?.showAlert(title: "Đăng nhập thất bại", message: error.message)
                }
            }
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
            loginButton.setTitle("Đang đăng nhập...", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            loginButton.setTitle("Đăng nhập", for: .normal)
        }
    }
    
    private func navigateToMainInterface() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case systemTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            otpTextField.becomeFirstResponder()
        case otpTextField:
            performLogin()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == systemTextField {
            systemPickerView.isHidden = false
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension LoginViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableSystems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableSystems[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        systemTextField.text = availableSystems[row]
    }
}
