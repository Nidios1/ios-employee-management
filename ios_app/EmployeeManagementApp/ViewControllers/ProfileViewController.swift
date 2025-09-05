import UIKit
import PhotosUI

class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    
    @IBOutlet weak var userInfoCard: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var systemLabel: UILabel!
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: - Properties
    private let authManager = AuthManager.shared
    private let networkManager = NetworkManager.shared
    private var currentUser: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUserData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Hồ sơ"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editProfileButtonTapped)
        )
        
        // Configure scroll view
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Configure avatar
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = UIColor.systemGray5
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        
        // Configure change avatar button
        changeAvatarButton.layer.cornerRadius = 8
        changeAvatarButton.backgroundColor = UIColor.systemBlue
        changeAvatarButton.setTitleColor(.white, for: .normal)
        
        // Configure user info card
        userInfoCard.layer.cornerRadius = 12
        userInfoCard.layer.shadowColor = UIColor.black.cgColor
        userInfoCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        userInfoCard.layer.shadowRadius = 4
        userInfoCard.layer.shadowOpacity = 0.1
        
        // Configure labels
        fullNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        positionLabel.font = UIFont.systemFont(ofSize: 16)
        departmentLabel.font = UIFont.systemFont(ofSize: 16)
        employeeIdLabel.font = UIFont.systemFont(ofSize: 16)
        systemLabel.font = UIFont.systemFont(ofSize: 16)
        
        // Configure buttons
        editProfileButton.layer.cornerRadius = 8
        editProfileButton.backgroundColor = UIColor.systemGreen
        editProfileButton.setTitleColor(.white, for: .normal)
        
        logoutButton.layer.cornerRadius = 8
        logoutButton.backgroundColor = UIColor.systemRed
        logoutButton.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - Data Loading
    private func loadUserProfile() {
        currentUser = authManager.currentUser
        updateUI()
    }
    
    private func refreshUserData() {
        // This would typically refresh user data from server
        loadUserProfile()
    }
    
    private func updateUI() {
        guard let user = currentUser else { return }
        
        // Update labels
        fullNameLabel.text = user.fullName
        emailLabel.text = user.email
        phoneLabel.text = user.phone ?? "Chưa cập nhật"
        positionLabel.text = user.position ?? "Chưa cập nhật"
        departmentLabel.text = user.department ?? "Chưa cập nhật"
        employeeIdLabel.text = user.employeeId ?? "Chưa cập nhật"
        systemLabel.text = authManager.currentSystemName
        
        // Load avatar
        if let avatarUrl = user.avatarUrl, !avatarUrl.isEmpty {
            loadAvatar(from: avatarUrl)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
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
    
    // MARK: - Actions
    @IBAction func changeAvatarButtonTapped(_ sender: UIButton) {
        showImagePickerOptions()
    }
    
    @IBAction func editProfileButtonTapped(_ sender: UIButton) {
        showEditProfileAlert()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        showLogoutConfirmation()
    }
    
    @objc private func editProfileButtonTapped() {
        showEditProfileAlert()
    }
    
    // MARK: - Image Picker
    private func showImagePickerOptions() {
        let alert = UIAlertController(title: "Chọn ảnh đại diện", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Chụp ảnh", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Chọn từ thư viện", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = changeAvatarButton
            popover.sourceRect = changeAvatarButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "Lỗi", message: "Nguồn ảnh không khả dụng")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    // MARK: - Edit Profile
    private func showEditProfileAlert() {
        let alert = UIAlertController(title: "Chỉnh sửa hồ sơ", message: "Tính năng chỉnh sửa hồ sơ sẽ được thêm trong phiên bản sau", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            showAlert(title: "Lỗi", message: "Không thể chọn ảnh")
            return
        }
        
        // Update avatar image
        avatarImageView.image = image
        
        // Here you would typically upload the image to the server
        // For now, we'll just show a success message
        showAlert(title: "Thành công", message: "Ảnh đại diện đã được cập nhật")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
