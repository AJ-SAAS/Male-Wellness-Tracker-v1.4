import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var testStore = TestStore()
    @State private var showAuth = false
    @State private var showInput = false

    var body: some View {
        NavigationStack {
            if authManager.isSignedIn {
                VStack {
                    Text("Tests count: \(testStore.tests.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    if testStore.tests.isEmpty {
                        Text("Start Tracking Wellness")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .padding()
                        Button("Add Test Results") {
                            showInput = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Add Test Results")
                    } else {
                        VStack {
                            Text("Latest Wellness Metrics")
                                .font(.title2)
                                .fontDesign(.rounded)
                            if let latest = testStore.tests.last {
                                DashboardSummary(test: latest)
                            }
                            List {
                                ForEach(testStore.tests) { test in
                                    NavigationLink(destination: ResultsView(test: test)) {
                                        Text("Fertility Log on \(test.date, format: .dateTime.day().month().year())")
                                    }
                                    .accessibilityLabel("View test from \(test.date, format: .dateTime.day().month().year())")
                                }
                                .onDelete { indices in
                                    testStore.deleteTests(at: indices)
                                }
                            }
                        }
                    }
                    Text("Version 1.5")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Add Test Results") {
                            showInput = true
                        }
                        .tint(.blue)
                        .accessibilityLabel("Add Test Results")
                        Button(action: {
                            authManager.signOut()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Sign Out")
                    }
                }
                .sheet(isPresented: $showInput) {
                    TestInputView()
                        .environmentObject(testStore)
                }
            } else {
                VStack {
                    Image(systemName: "waveform.path")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Wellness Tracker Icon")
                    Text("Welcome to Male Wellness Tracker")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .padding()
                    Text("Track your reproductive metrics privately for personal insight.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Button("Get Started") {
                        showAuth = true
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .accessibilityLabel("Get Started")
                }
                .navigationTitle("Welcome")
                .sheet(isPresented: $showAuth) {
                    AuthView()
                        .environmentObject(authManager)
                }
            }
        }
        .environmentObject(testStore)
    }
}

struct DashboardSummary: View {
    let test: TestData

    var body: some View {
        VStack {
            Text("Overall: \(test.overallStatus)")
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundColor(test.overallStatus == "Balanced" ? .green : .orange)
                .accessibilityLabel("Overall status: \(test.overallStatus)")
            HStack {
                StatusBox(title: "Analysis", status: test.analysisStatus)
                StatusBox(title: "Motility", status: test.motilityStatus)
            }
            HStack {
                StatusBox(title: "Concentration", status: test.concentrationStatus)
                StatusBox(title: "Morphology", status: test.morphologyStatus)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
    }
}

