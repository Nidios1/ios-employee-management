import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private var messages: [ChatMessage] = []
    private var isTyping = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadChatHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure navigation bar
        navigationItem.title = "Chat AI"
        navigationItem.rightBarButtonItems = [clearButton, refreshButton]
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure message input
        messageInputView.layer.cornerRadius = 20
        messageInputView.layer.borderWidth = 1
        messageInputView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputView.backgroundColor = UIColor.systemBackground
        
        messageTextField.delegate = self
        messageTextField.placeholder = "Nhập câu hỏi của bạn..."
        messageTextField.returnKeyType = .send
        
        sendButton.layer.cornerRadius = 16
        sendButton.backgroundColor = UIColor.systemBlue
        sendButton.setTitle("Gửi", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Data Loading
    private func loadChatHistory() {
        setLoading(true)
        
        networkManager.getChatHistory { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.messages = response.messages
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    } else {
                        self?.showAlert(title: "Lỗi", message: "Không thể tải lịch sử chat")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        refreshButton.isEnabled = !isLoading
        clearButton.isEnabled = !isLoading
        sendButton.isEnabled = !isLoading
        messageTextField.isEnabled = !isLoading
        
        if isLoading {
            sendButton.setTitle("Đang gửi...", for: .normal)
        } else {
            sendButton.setTitle("Gửi", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendMessage()
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        clearChatHistory()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        loadChatHistory()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Message Handling
    private func sendMessage() {
        guard let messageText = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !messageText.isEmpty else {
            return
        }
        
        // Add user message to UI immediately
        let userMessage = ChatMessage(
            question: messageText,
            answer: "",
            createdAt: DateFormatter.iso8601.string(from: Date())
        )
        
        messages.append(userMessage)
        messageTextField.text = ""
        tableView.reloadData()
        scrollToBottom()
        
        // Send to server
        setLoading(true)
        
        networkManager.sendChatMessage(question: messageText) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    if response.success, let answer = response.answer {
                        // Update the last message with the AI response
                        if let lastIndex = self?.messages.indices.last {
                            self?.messages[lastIndex] = ChatMessage(
                                question: messageText,
                                answer: answer,
                                createdAt: self?.messages[lastIndex].createdAt ?? ""
                            )
                        }
                        
                        // Save to history
                        self?.saveMessageToHistory(question: messageText, answer: answer)
                        
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    } else {
                        self?.showAlert(title: "Lỗi", message: response.message ?? "Không thể gửi tin nhắn")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Lỗi", message: error.message)
                }
            }
        }
    }
    
    private func saveMessageToHistory(question: String, answer: String) {
        networkManager.saveChatMessage(question: question, answer: answer) { result in
            switch result {
            case .success:
                print("Message saved to history")
            case .failure(let error):
                print("Failed to save message: \(error.message)")
            }
        }
    }
    
    private func clearChatHistory() {
        let alert = UIAlertController(title: "Xóa lịch sử", message: "Bạn có chắc chắn muốn xóa toàn bộ lịch sử chat?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            self?.performClearHistory()
        })
        
        present(alert, animated: true)
    }
    
    private func performClearHistory() {
        setLoading(true)
        
        // Clear local messages
        messages.removeAll()
        tableView.reloadData()
        
        // Clear server history
        // Note: This would require implementing a clear history API endpoint
        setLoading(false)
        showAlert(title: "Thành công", message: "Đã xóa lịch sử chat")
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration) {
            self.view.transform = .identity
        }
    }
    
    // MARK: - Helper Methods
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        
        let lastIndexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - Custom Table View Cell
class ChatMessageTableViewCell: UITableViewCell {
    
    private let messageBubble = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Configure message bubble
        messageBubble.layer.cornerRadius = 16
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageBubble)
        
        // Configure message label
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageBubble.addSubview(messageLabel)
        
        // Configure time label
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray2
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            messageBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageBubble.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4),
            messageBubble.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            
            messageLabel.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -12),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            timeLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with message: ChatMessage) {
        // Determine if this is a user question or AI answer
        let isUserMessage = !message.question.isEmpty && message.answer.isEmpty
        let messageText = isUserMessage ? message.question : message.answer
        
        messageLabel.text = messageText
        
        // Configure appearance based on message type
        if isUserMessage {
            // User message - right aligned, blue background
            messageBubble.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white
            
            NSLayoutConstraint.activate([
                messageBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
        } else {
            // AI message - left aligned, gray background
            messageBubble.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .label
            
            NSLayoutConstraint.activate([
                messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            ])
        }
        
        // Format time
        if let date = DateFormatter.iso8601.date(from: message.createdAt) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = message.createdAt
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}
