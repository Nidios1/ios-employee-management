import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello, World! 🌍")
                .font(.title)
                .fontWeight(.bold)
            
            Text("iOS App Build Success! ✅")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Kết nối với PHP Server")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
