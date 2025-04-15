import FirebaseAuth

class AuthService {
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            completion(error)
        }
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}
