import SwiftUI
import AVKit

struct HomeView: View {
    private let piggyPlayer = AVPlayer(url: Bundle.main.url(forResource: "piggy_intro", withExtension: "mp4")!)

    var body: some View {
        NavigationStack { // Add NavigationStack
            ZStack {
                // Background video without controls
                VideoBackground(player: piggyPlayer)
                    .ignoresSafeArea()

                // Log In / Sign Up buttons
                VStack {
                    Spacer()

                    HStack(spacing: 20) {
                        NavigationLink(destination: LoginView()) {
                            Text("Log in")
                                .font(.headline)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        NavigationLink(destination: SignUpView()) {
                            Text("Sign up")
                                .font(.headline)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            .onAppear {
                piggyPlayer.play()
                loopVideo(player: piggyPlayer)
            }
        }
    }

    private func loopVideo(player: AVPlayer) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}

struct VideoBackground: UIViewRepresentable {
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
