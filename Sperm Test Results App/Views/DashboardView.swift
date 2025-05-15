import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Top Row: Welcome + Plus Button
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome")
                                .font(.title)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text(formattedDate())
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.gray.opacity(0.8))
                        }

                        Spacer()

                        Button(action: {
                            showInput = true
                        }) {
                            Image(systemName: "plus")
                                .font(.body.bold())
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "66B0F0"))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Add New Test")
                    }
                    .padding(.horizontal)

                    if !testStore.tests.isEmpty {
                        let averages = calculateAverages()
                        let trend = calculateTrend()

                        HStack(alignment: .top, spacing: 16) {
                            OverallScoreCard(
                                overallScore: averages.overallScore,
                                trend: trend
                            )
                            .frame(maxWidth: .infinity, maxHeight: 160)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fertility Snapshot")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.black)

                                NavigationLink(destination: TrackView()) {
                                    Text("View Full Report >")
                                        .font(.subheadline.bold())
                                        .fontDesign(.rounded)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color(hex: "66B0F0"))
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("View Full Report")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.1), radius: 5)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                    }

                    // Middle Section
                    Text("Recent Tests")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if testStore.tests.isEmpty {
                        VStack(spacing: 8) {
                            Text("No tests available.")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.gray)

                            Text("Tap the + button above to add your first test.")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .padding(.horizontal)
                    } else {
                        ForEach(testStore.tests.prefix(3)) { test in
                            NavigationLink(destination: ResultsView(test: test)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(test.dateFormatted)
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.black)

                                        Text("• \(test.overallStatus)")
                                            .font(.subheadline)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .padding(.horizontal)
                        }
                    }

                    Text("Visualizations are based on WHO 6th Edition standards for informational purposes only. Fathr is not a medical device. Consult a doctor for fertility concerns.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top)
                }
                .padding(.vertical)
            }
            .background(Color.white)
            .navigationTitle("")
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
            }
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private struct Averages {
        let overallScore: Int
        let motility: Int
        let concentration: Int
        let morphology: Int
        let dnaFragmentation: Int?
        let spermAnalysis: Int
    }

    private func calculateAverages() -> Averages {
        let count = testStore.tests.count
        guard count > 0 else {
            return Averages(overallScore: 0, motility: 0, concentration: 0, morphology: 0, dnaFragmentation: nil, spermAnalysis: 0)
        }

        let totalMotility = testStore.tests.reduce(0) { $0 + Int($1.totalMobility) }
        let totalConcentration = testStore.tests.reduce(0) { $0 + Int($1.spermConcentration / 100 * 100) }
        let totalMorphology = testStore.tests.reduce(0) { $0 + Int($1.morphologyRate) }

        let dnaScores = testStore.tests.map { test in
            test.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80
        }
        let totalDnaFragmentation = dnaScores.reduce(0, +)

        let totalSpermAnalysis = testStore.tests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }

        let avgMotility = totalMotility / count
        let avgConcentration = totalConcentration / count
        let avgMorphology = totalMorphology / count
        let avgDnaFragmentation = totalDnaFragmentation / count
        let avgSpermAnalysis = totalSpermAnalysis / count

        let scores = [avgMotility, avgConcentration, avgMorphology, avgDnaFragmentation, avgSpermAnalysis]
        let overallScore = scores.reduce(0, +) / scores.count

        return Averages(overallScore: overallScore,
                        motility: avgMotility,
                        concentration: avgConcentration,
                        morphology: avgMorphology,
                        dnaFragmentation: avgDnaFragmentation,
                        spermAnalysis: avgSpermAnalysis)
    }

    private func calculateTrend() -> TrackView.Trend {
        guard testStore.tests.count > 1 else { return .none }

        let currentScores = [
            Int(testStore.tests[0].totalMobility),
            Int(testStore.tests[0].spermConcentration / 100 * 100),
            Int(testStore.tests[0].morphologyRate),
            testStore.tests[0].dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80,
            mapAnalysisStatusToScore(testStore.tests[0].analysisStatus)
        ]
        let currentOverall = currentScores.reduce(0, +) / currentScores.count

        let previousTests = Array(testStore.tests.dropFirst())

        let totalMotility = previousTests.reduce(0) { $0 + Int($1.totalMobility) }
        let totalConcentration = previousTests.reduce(0) { $0 + Int($1.spermConcentration / 100 * 100) }
        let totalMorphology = previousTests.reduce(0) { $0 + Int($1.morphologyRate) }
        let totalDna = previousTests.reduce(0) { $0 + ($1.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80) }
        let totalAnalysis = previousTests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }

        let previousOverall = (totalMotility + totalConcentration + totalMorphology + totalDna + totalAnalysis) / (previousTests.count * 5)

        if currentOverall > previousOverall { return .up }
        if currentOverall < previousOverall { return .down }
        return .none
    }

    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical": return 80
        case "atypical": return 40
        default: return 50
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(TestStore())
    }
}

