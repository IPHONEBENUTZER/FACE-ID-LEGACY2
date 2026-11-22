import SwiftUI

struct ContentView: View {
    @State private var isScanning = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("FaceID Legacy")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Image(systemName: "faceid")
                    .font(.system(size: 100))
                    .foregroundColor(.cyan)

                Text(isScanning ? "Scanning..." : "Ready to scan")
                    .foregroundColor(.white)

                Button(action: {
                    isScanning.toggle()
                }) {
                    Text("Start Face Scan")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(15)
                }
            }
        }
    }
}
