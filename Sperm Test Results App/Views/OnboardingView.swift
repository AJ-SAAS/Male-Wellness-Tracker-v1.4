import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Welcome to Fathr")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // App Value
            Text("Unlock personalized sperm insights, visual graphs, and expert analysis.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            // Tease Free Trial
            Text("Start with a 3-day free trial!")
                .font(.headline)
                .foregroundColor(.blue)

            // Sample Graph Placeholder (visual teaser)
            Image(systemName: "chart.bar.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.gray)
                .accessibilityLabel("Sample sperm analysis graph")

            // Testimonials
            Text("“Fathr helped me understand my fertility better!” – John D.")
                .font(.caption)
                .italic()
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            // Privacy Assurance
            Text("🔒 HIPAA-compliant • Your data is secure")
                .font(.caption)
                .foregroundColor(.gray)

            // Continue Button
            Button(action: {
                print("OnboardingView: Continue button clicked")
                hasSeenOnboarding = true
                // Save to UserDefaults so onboarding only shows once
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                print("OnboardingView: hasSeenOnboarding set to true")
            }) {
                Text("Continue")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .accessibilityLabel("Continue to sign up")
        }
        .padding()
        .onChange(of: hasSeenOnboarding) { newValue in
            print("OnboardingView: hasSeenOnboarding changed to \(newValue)")
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
            .environmentObject(PurchaseModel())
    }
}
