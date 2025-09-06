import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World! 🌍")
                .font(.title)
                .padding()
            
            Text("iOS Build Success! ✅")
                .font(.headline)
                .foregroundColor(.green)
        }
    }
}

#Preview {
    ContentView()
}
