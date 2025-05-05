import SwiftUI
import FirebaseCore

@main
struct Sperm_Test_Results_AppApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(authManager)
        }
    }
}
