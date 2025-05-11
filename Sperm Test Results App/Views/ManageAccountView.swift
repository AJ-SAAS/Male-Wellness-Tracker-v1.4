import SwiftUI
import FirebaseAuth // Added import

struct ManageAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @State private var showResetPassword = false
    @State private var emailForReset = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Account Actions")) {
                // Sign Out Button
                Button(action: {
                    authManager.signOut()
                    showAlert = true
                    alertMessage = authManager.errorMessage ?? "Signed out successfully"
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Sign Out")
                
                // Delete Account Button
                Button(action: {
                    deleteAccount()
                }) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Delete Account")
            }
            
            Section(header: Text("Reset Password")) {
                TextField("Enter email", text: $emailForReset)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button(action: {
                    authManager.resetPassword(email: emailForReset)
                    showAlert = true
                    alertMessage = authManager.errorMessage ?? "Password reset email sent"
                }) {
                    Text("Send Password Reset Email")
                }
                .disabled(!isValidEmail(emailForReset))
                .accessibilityLabel("Send Password Reset Email")
            }
        }
        .navigationTitle("Manage Account")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Account Action"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            authManager.errorMessage = "No user signed in"
            showAlert = true
            alertMessage = authManager.errorMessage!
            return
        }
        
        testStore.deleteAllTestsForUser(userId: user.uid) { success in
            if success {
                authManager.deleteAccount()
                showAlert = true
                alertMessage = authManager.errorMessage ?? "Account deleted successfully"
            } else {
                authManager.errorMessage = "Failed to delete user data"
                showAlert = true
                alertMessage = authManager.errorMessage!
            }
        }
    }
    
    // Email validation (copied from AuthManager for consistency)
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAccountView()
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
    }
}

