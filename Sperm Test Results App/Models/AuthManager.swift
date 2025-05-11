import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUserID: String? // Added property
    @Published var errorMessage: String?
    
    init() {
        if let user = Auth.auth().currentUser {
            isSignedIn = true
            currentUserID = user.uid
        }
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isSignedIn = user != nil
            self?.currentUserID = user?.uid
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
            self?.currentUserID = result?.user.uid
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
            self?.currentUserID = result?.user.uid
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            currentUserID = nil
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
            self?.currentUserID = nil
            self?.errorMessage = "Account deleted"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}
