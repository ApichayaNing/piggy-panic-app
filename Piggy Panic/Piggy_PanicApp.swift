import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Piggy_PanicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate  // Connect AppDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
            // Start with your intro screen
                .preferredColorScheme(.light)
        }
    }
}
