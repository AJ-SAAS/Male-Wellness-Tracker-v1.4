import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Sign Up") {
                UserDefaults.standard.set(email, forKey: "userEmail")
                isLoggedIn = true
                dismiss()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty)
        }
        .navigationTitle("Sign Up")
        .padding()
    }
}

#Preview {
    SignUpView(isLoggedIn: .constant(false))
}
