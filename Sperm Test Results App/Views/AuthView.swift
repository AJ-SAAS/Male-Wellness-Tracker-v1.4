import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.path")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .accessibilityLabel("Wellness Tracker Icon")
            
            Text(isSignUp ? "Create Account" : "Sign In")
                .font(.title2)
                .fontDesign(.rounded)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .accessibilityLabel("Email")
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .accessibilityLabel("Password")
            
            if let error = authManager.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: {
                isLoading = true
                if isSignUp {
                    authManager.signUp(email: email, password: password)
                } else {
                    authManager.signIn(email: email, password: password)
                }
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .fontDesign(.rounded)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty)
            .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")
            .onChange(of: authManager.isSignedIn) { _ in
                isLoading = false
                if authManager.isSignedIn {
                    dismiss()
                }
            }
            .onChange(of: authManager.errorMessage) { _ in
                isLoading = false
            }
            
            if !isSignUp {
                Button(action: {
                    isLoading = true
                    authManager.resetPassword(email: email)
                }) {
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .accessibilityLabel("Forgot Password")
                .onChange(of: authManager.errorMessage) { _ in
                    isLoading = false
                }
            }
            
            Button(action: {
                isSignUp.toggle()
                authManager.errorMessage = nil
            }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                .foregroundColor(.blue)
            }
            .padding()
            .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")
        }
        .padding()
    }
}

#Preview {
    AuthView().environmentObject(AuthManager())
}
