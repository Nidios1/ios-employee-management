import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var username = ""
    @State private var password = ""
    @State private var totpCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Employee Management")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("Đăng nhập vào hệ thống")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                TextField("Tên đăng nhập", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Mật khẩu", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Mã TOTP", text: $totpCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 30)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Đăng nhập")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 30)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
    }
    
    private func login() {
        guard !username.isEmpty && !password.isEmpty && !totpCode.isEmpty else {
            errorMessage = "Vui lòng điền đầy đủ thông tin"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        authManager.login(username: username, password: password, totpCode: totpCode)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = "Lỗi đăng nhập: \(error.localizedDescription)"
                    }
                },
                receiveValue: { success in
                    if !success {
                        errorMessage = "Tên đăng nhập, mật khẩu hoặc mã TOTP không đúng"
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

#Preview {
    LoginView()
}
