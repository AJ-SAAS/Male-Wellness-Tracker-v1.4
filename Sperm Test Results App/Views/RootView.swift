import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !authManager.isSignedIn || Auth.auth().currentUser?.isAnonymous == true {
                AuthView()
            } else {
                TabBarView()
            }
        }
        .onAppear {
            print("RootView: hasCompletedOnboarding = \(hasCompletedOnboarding), isSignedIn = \(authManager.isSignedIn), isAnonymous = \(Auth.auth().currentUser?.isAnonymous ?? false)")
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}
