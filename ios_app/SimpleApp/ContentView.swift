import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello World! 🎉")
                .font(.largeTitle)
                .padding()
            
            Text("iOS Build Success!")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
