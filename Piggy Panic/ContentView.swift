import SwiftUI
import FirebaseAuth
import AVKit

struct ContentView: View {
    @Environment(\.dismiss) var dismiss  // For log out navigation
    private let homepagePlayer = AVPlayer(url: Bundle.main.url(forResource: "Homepage", withExtension: "mp4")!)

    var body: some View {
        NavigationStack {
            ZStack {
                // Background video
                DashboardBackground(player: homepagePlayer)
                    .ignoresSafeArea()

                VStack {
                    Spacer()  // Push everything down

                    // Add space under the yellow rectangle
                    Spacer().frame(height: 500)

                    // Buttons
                    VStack(spacing: 15) {
                        NavigationLink(destination: GoalSettingView()) {
                            Text("Create New Goal")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        NavigationLink(destination: MyGoalsView()) {
                            Text("View My Goals")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.pink.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: logOut) {
                            Text("Log Out")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 10)  // Padding below the buttons

                    Spacer()  // For padding at the bottom
                }
                .padding()
            }
            .onAppear {
                homepagePlayer.play()
                loopVideo(player: homepagePlayer)
            }
        }
    }

    // Log out function
    func logOut() {
        do {
            try Auth.auth().signOut()
            dismiss()  // Return to HomeView
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // Looping function for background video
    private func loopVideo(player: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}

// Background video view
struct DashboardBackground: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


