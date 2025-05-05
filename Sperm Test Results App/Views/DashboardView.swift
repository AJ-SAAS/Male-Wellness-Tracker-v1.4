import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false

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
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(TestStore())
    }
}
