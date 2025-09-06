import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        if authManager.isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
