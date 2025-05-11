import SwiftUI
import FirebaseAnalytics

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var purchaseModel = PurchaseModel()
    @State private var showInput = false
    @State private var showPurchaseSheet = false
    @AppStorage("analyticsConsent") private var analyticsConsent = false
    @State private var showConsentPrompt = true

    var body: some View {
        NavigationStack {
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
                        
                        Button(action: {
                            if purchaseModel.isSubscribed {
                                print("Accessing premium analysis...")
                            } else {
                                showPurchaseSheet = true
                            }
                        }) {
                            Text("View Advanced Analysis")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(purchaseModel.isSubscribed ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .accessibilityLabel("View Advanced Analysis")
                        
                        List {
                            ForEach(testStore.tests) { test in
                                NavigationLink(destination: ResultsView(test: test)
                                    .environmentObject(purchaseModel)) {
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
                
                Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Test Results") {
                        showInput = true
                    }
                    .tint(.blue)
                    .accessibilityLabel("Add Test Results")
                }
            }
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
            }
            .fullScreenCover(isPresented: $showPurchaseSheet) {
                PurchaseView(isPresented: $showPurchaseSheet, purchaseModel: purchaseModel)
            }
            .sheet(isPresented: $showConsentPrompt, onDismiss: {
                if !analyticsConsent {
                    Analytics.setAnalyticsCollectionEnabled(false)
                }
            }) {
                AnalyticsConsentView()
            }
            .onAppear {
                showConsentPrompt = !UserDefaults.standard.bool(forKey: "hasSeenConsentPrompt")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowPaywall"))) { _ in
                showPurchaseSheet = true
            }
        }
        .environmentObject(purchaseModel)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(TestStore())
            .environmentObject(AuthManager())
            .environmentObject(PurchaseModel())
    }
}
