import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    init() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        }
    }
    
    func signUp(email: String, password: String) {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isSignedIn = true
        }
    }
    
    func signIn(email: String, password: String) {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isSignedIn = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.errorMessage = "Password reset email sent"
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        user.delete { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isSignedIn = false
            self?.errorMessage = "Account deleted"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}
