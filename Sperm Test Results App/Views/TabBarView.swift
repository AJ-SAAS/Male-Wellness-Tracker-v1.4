import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var purchaseModel: PurchaseModel
    @StateObject private var testStore = TestStore()

    var body: some View {
        if authManager.isSignedIn {
            TabView {
                // Home Tab (Dashboard)
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                
                // Track Tab (Results or Prompt)
                TrackView()
                    .tabItem {
                        Label("Track", systemImage: "plus.circle")
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                
                // More Tab (Settings)
                SettingsView()
                    .tabItem {
                        Label("More", systemImage: "gear")
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
            .environmentObject(authManager)
        } else {
            // Show AuthView if not signed in
            AuthView()
                .environmentObject(authManager)
                .environmentObject(purchaseModel)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(AuthManager())
            .environmentObject(PurchaseModel())
            .environmentObject(TestStore())
    }
}
