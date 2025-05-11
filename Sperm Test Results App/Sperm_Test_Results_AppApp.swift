import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import RevenueCat

@main
struct Sperm_Test_Results_AppApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var testStore = TestStore()
    @StateObject private var purchaseModel = PurchaseModel()
    
    init() {
        // Initialize Firebase
        do {
            FirebaseApp.configure()
            Analytics.setAnalyticsCollectionEnabled(false) // Disable Analytics by default
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false) // Disable Crashlytics by default
        } catch {
            print("Firebase configuration failed: \(error.localizedDescription)")
        }
        
        // Initialize RevenueCat
        Purchases.configure(withAPIKey: "appl_rhIxpzSZfMAgajJHLURLcNHmThg")
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(authManager)
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
                .onAppear {
                    // Sync RevenueCat with Firebase user ID (if available)
                    if let userID = authManager.currentUserID {
                        Purchases.shared.logIn(userID) { (customerInfo, created, error) in
                            if let error = error {
                                print("RevenueCat login error: \(error.localizedDescription)")
                            } else {
                                print("RevenueCat logged in user: \(userID)")
                            }
                        }
                    }
                }
        }
    }
}
