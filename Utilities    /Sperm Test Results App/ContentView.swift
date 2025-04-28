import SwiftUI

struct ContentView: View {
    @StateObject private var testStore = TestStore()
    @State private var isLoggedIn = UserDefaults.standard.string(forKey: "userEmail") != nil
    @State private var showSignUp = false
    @State private var showInput = false

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                VStack {
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
                                        Text("Metrics on \(test.date, format: .dateTime.day().month().year())")
                                    }
                                    .accessibilityLabel("View test from \(test.date, format: .dateTime.day().month().year())")
                                }
                                .onDelete { indices in
                                    testStore.tests.remove(atOffsets: indices)
                                }
                            }
                        }
                    }
                    Text("Version 1.4")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .navigationTitle("Wellness Dashboard")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Test Results") {
                            showInput = true
                        }
                        .tint(.blue)
                        .accessibilityLabel("Add Test Results")
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        Button("Logout") {
                            UserDefaults.standard.removeObject(forKey: "userEmail")
                            isLoggedIn = false
                            testStore.tests.removeAll()
                        }
                        .accessibilityLabel("Logout")
                    }
                }
                .sheet(isPresented: $showInput) {
                    TestInputView()
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
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .accessibilityLabel("Sign Up")
                }
                .navigationTitle("Welcome")
                .sheet(isPresented: $showSignUp) {
                    SignUpView(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .environmentObject(testStore)
    }
}

struct DashboardSummary: View {
    let test: SpermTest

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

struct StatusBox: View {
    let title: String
    let status: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .fontDesign(.rounded)
            Text(status)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(status == "Typical" || status == "Active" ? .green : .orange)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status: \(status)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
