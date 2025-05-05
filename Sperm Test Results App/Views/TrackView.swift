import SwiftUI

struct TrackView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false
    
    var body: some View {
        NavigationStack {
            if testStore.tests.isEmpty {
                // No tests: Prompt to upload
                VStack(spacing: 20) {
                    Image(systemName: "waveform.path")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Wellness Tracker Icon")
                    
                    Text("Upload your first test to start tracking progress")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Upload New Test") {
                        showInput = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .accessibilityLabel("Upload New Test")
                }
                .navigationTitle("Track")
                .sheet(isPresented: $showInput) {
                    TestInputView()
                        .environmentObject(testStore)
                }
            } else {
                // Tests exist: Show latest results
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Overall Score
                        if let latestTest = testStore.tests.first {
                            let (score, scoreLabel) = calculateOverallScore(test: latestTest)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Latest Overall Score")
                                    .font(.title2)
                                    .fontDesign(.rounded)
                                
                                Text("\(score)/100 – \(scoreLabel)")
                                    .font(.headline)
                                    .foregroundColor(scoreColor(score: score))
                                    .accessibilityLabel("Overall score: \(score) out of 100, \(scoreLabel)")
                                
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 10)
                                            .cornerRadius(5)
                                        
                                        Rectangle()
                                            .fill(scoreGradient(score: score))
                                            .frame(width: geometry.size.width * CGFloat(score) / 100, height: 10)
                                            .cornerRadius(5)
                                    }
                                }
                                .frame(height: 10)
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            
                            // Categories
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category Breakdown")
                                    .font(.title3)
                                    .fontDesign(.rounded)
                                    .padding(.bottom, 4)
                                
                                CategoryRow(title: "Analysis", status: latestTest.analysisStatus, destination: ResultsView(test: latestTest))
                                CategoryRow(title: "Motility", status: latestTest.motilityStatus, destination: ResultsView(test: latestTest))
                                CategoryRow(title: "Morphology", status: latestTest.morphologyStatus, destination: ResultsView(test: latestTest))
                                CategoryRow(title: "Concentration", status: latestTest.concentrationStatus, destination: ResultsView(test: latestTest))
                                if let dnaRisk = latestTest.dnaFragmentationRisk, let category = latestTest.dnaRiskCategory {
                                    CategoryRow(title: "DNA Fragmentation", status: "\(dnaRisk)% (\(category))", destination: ResultsView(test: latestTest))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Track")
            }
        }
    }
    
    // Calculate overall score and label
    private func calculateOverallScore(test: SpermTest) -> (Int, String) {
        // Example scoring logic: Average key metrics
        let motilityScore = min(Int(test.totalMobility), 100) // 0–100%
        let concentrationScore = min(Int(test.spermConcentration / 100 * 100), 100) // Normalize 0–100 M/mL to 0–100
        let morphologyScore = min(Int(test.morphologyRate), 100) // 0–100%
        let dnaScore = test.dnaFragmentationRisk.map { min(Int((100 - $0) / 100 * 100), 100) } ?? 80 // Inverse of risk, default 80 if nil
        
        let scores = [motilityScore, concentrationScore, morphologyScore, dnaScore]
        let average = scores.reduce(0, +) / scores.count
        
        // Map score to label
        let label: String
        switch average {
        case 0..<50: label = "Poor"
        case 50..<70: label = "Fair"
        case 70..<85: label = "Good"
        case 85...100: label = "Excellent"
        default: label = "Fair"
        }
        
        return (average, label)
    }
    
    // Color for score text
    private func scoreColor(score: Int) -> Color {
        switch score {
        case 0..<50: return .red
        case 50..<70: return .orange
        case 70..<85: return .yellow
        case 85...100: return .green
        default: return .gray
        }
    }
    
    // Gradient for progress bar
    private func scoreGradient(score: Int) -> LinearGradient {
        let colors: [Color]
        switch score {
        case 0..<50: colors = [.red, .orange]
        case 50..<70: colors = [.orange, .yellow]
        case 70..<85: colors = [.yellow, .green]
        case 85...100: colors = [.green, .green.opacity(0.8)]
        default: colors = [.gray, .gray]
        }
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
    }
}

// Category Row View
struct CategoryRow: View {
    let title: String
    let status: String
    let destination: ResultsView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.body)
                    .fontDesign(.rounded)
                
                Spacer()
                
                Text(statusWithEmoji(status: status))
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundColor(statusColor(status: status))
            }
            .padding(.vertical, 4)
            .accessibilityLabel("\(title): \(status)")
        }
    }
    
    private func statusWithEmoji(status: String) -> String {
        switch status.lowercased() {
        case "normal", "good", "excellent", "low": return "\(status) ✅"
        case "needs work", "poor", "high": return "\(status) ⚠️"
        case let s where s.contains("great"): return "\(status) 🌟"
        default: return status
        }
    }
    
    private func statusColor(status: String) -> Color {
        switch status.lowercased() {
        case "normal", "good", "excellent", "low": return .green
        case "needs work", "poor", "high": return .orange
        case let s where s.contains("great"): return .blue
        default: return .gray
        }
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
            .environmentObject(TestStore())
    }
}
