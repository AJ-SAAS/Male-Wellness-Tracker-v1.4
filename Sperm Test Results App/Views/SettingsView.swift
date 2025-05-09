import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    if let user = Auth.auth().currentUser {
                        Text("Email: \(user.email ?? "N/A")")
                            .accessibilityLabel("Email: \(user.email ?? "Not available")")
                    }
                    NavigationLink("Manage Account", destination: ManageAccountView())
                        .accessibilityLabel("Manage Account")
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    Link("Contact Support", destination: URL(string: "mailto:fathrapp@gmail.com")!)
                        .accessibilityLabel("Contact Support via Email")
                    Link("Visit Our Website", destination: URL(string: "https://www.fathr.xyz")!)
                        .accessibilityLabel("Visit Website")
                }
                
                // Legal Section
                Section(header: Text("Legal")) {
                    Link("Terms of Use", destination: URL(string: "https://www.fathr.xyz/r/terms")!)
                        .accessibilityLabel("Terms of Service")
                    Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                        .accessibilityLabel("Privacy Policy")
                }
                
                // In-App Purchases (Placeholder)
                if hasInAppPurchases {
                    Section {
                        Button("Restore Purchases") {
                            // Add StoreKit restore purchases logic here
                            print("Restoring purchases...")
                        }
                        .accessibilityLabel("Restore Purchases")
                    }
                }
                
                // Account Actions
                Section {
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Log Out")
                    .alert("Log Out", isPresented: $showingLogoutAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Log Out", role: .destructive) {
                            authManager.signOut()
                        }
                    } message: {
                        Text("Are you sure you want to log out?")
                    }
                    
                    Button("Delete Account") {
                        showingDeleteAccountAlert = true
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Delete Account")
                    .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            deleteAccount()
                        }
                    } message: {
                        Text("This will permanently delete your account and all associated data. Are you sure?")
                    }
                }
                
                // App Info
                Section {
                    Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                        .accessibilityLabel("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private var hasInAppPurchases: Bool {
        // Change to true if you add in-app purchases
        return false
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete Firestore data first
        testStore.deleteAllTestsForUser(userId: user.uid) { success in
            if success {
                // Delete Firebase Authentication account
                authManager.deleteAccount()
            } else {
                authManager.errorMessage = "Failed to delete user data"
            }
        }
    }
}

struct ManageAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var showingError = false
    
    var body: some View {
        Form {
            Section(header: Text("Update Email")) {
                TextField("New Email", text: $newEmail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .accessibilityLabel("New Email")
                Button("Update Email") {
                    if let user = Auth.auth().currentUser, !newEmail.isEmpty {
                        user.updateEmail(to: newEmail) { error in
                            if let error = error {
                                authManager.errorMessage = error.localizedDescription
                                showingError = true
                            } else {
                                authManager.errorMessage = "Email updated successfully"
                            }
                        }
                    }
                }
                .accessibilityLabel("Update Email")
            }
            
            Section(header: Text("Update Password")) {
                SecureField("New Password", text: $newPassword)
                    .accessibilityLabel("New Password")
                Button("Update Password") {
                    if let user = Auth.auth().currentUser, !newPassword.isEmpty {
                        user.updatePassword(to: newPassword) { error in
                            if let error = error {
                                authManager.errorMessage = error.localizedDescription
                                showingError = true
                            } else {
                                authManager.errorMessage = "Password updated successfully"
                            }
                        }
                    }
                }
                .accessibilityLabel("Update Password")
            }
            
            if let error = authManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .accessibilityLabel("Error: \(error)")
            }
        }
        .navigationTitle("Manage Account")
        .onChange(of: showingError) { _ in
            if showingError {
                authManager.errorMessage = nil
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
    }
}
