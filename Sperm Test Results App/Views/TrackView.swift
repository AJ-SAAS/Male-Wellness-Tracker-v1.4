import SwiftUI

struct TrackView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if testStore.tests.isEmpty {
                        Text("No test results yet.")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.gray)
                    } else {
                        // Compute averages and trend
                        let averages = calculateAverages()
                        let trend = calculateTrend()
                        
                        // Overall Score Card
                        OverallScoreCard(
                            overallScore: averages.overallScore,
                            trend: trend
                        )
                        
                        // Fertility Status Section
                        FertilityStatusView(
                            motility: averages.motility,
                            concentration: averages.concentration,
                            morphology: averages.morphology,
                            dnaFragmentation: averages.dnaFragmentation,
                            spermAnalysis: averages.spermAnalysis
                        )
                        
                        // View Past Results Button
                        if testStore.tests.count > 1 {
                            NavigationLink(destination: PastResultsView()) {
                                Text("View Past Results")
                                    .font(.headline.bold())
                                    .fontDesign(.rounded)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "00D4B4").opacity(0.1))
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 0)
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Track")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
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
            }
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
            }
        }
    }
    
    // Struct to hold averaged values
    private struct Averages {
        let overallScore: Int
        let motility: Int
        let concentration: Int
        let morphology: Int
        let dnaFragmentation: Int?
        let spermAnalysis: Int
    }
    
    // Calculate averages across all tests
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
        
        let scores: [Int] = [
            avgMotility,
            avgConcentration,
            avgMorphology,
            avgDnaFragmentation,
            avgSpermAnalysis
        ]
        let overallScore = scores.reduce(0, +) / scores.count
        
        return Averages(
            overallScore: overallScore,
            motility: avgMotility,
            concentration: avgConcentration,
            morphology: avgMorphology,
            dnaFragmentation: avgDnaFragmentation,
            spermAnalysis: avgSpermAnalysis
        )
    }
    
    // Calculate trend for overall score
    private func calculateTrend() -> Trend {
        guard testStore.tests.count > 1 else { return .none }
        
        // Current average (most recent test)
        let currentScores: [Int] = [
            Int(testStore.tests[0].totalMobility),
            Int(testStore.tests[0].spermConcentration / 100 * 100),
            Int(testStore.tests[0].morphologyRate),
            testStore.tests[0].dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80,
            mapAnalysisStatusToScore(testStore.tests[0].analysisStatus)
        ]
        let currentOverall = currentScores.reduce(0, +) / currentScores.count
        
        // Previous average (all tests except the most recent)
        let previousTests = Array(testStore.tests.dropFirst())
        
        let totalMotility = previousTests.reduce(0) { $0 + Int($1.totalMobility) }
        let totalConcentration = previousTests.reduce(0) { $0 + Int($1.spermConcentration / 100 * 100) }
        let totalMorphology = previousTests.reduce(0) { $0 + Int($1.morphologyRate) }
        let totalDna = previousTests.reduce(0) { $0 + ($1.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80) }
        let totalAnalysis = previousTests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }
        
        let previousAverages = (
            motility: totalMotility,
            concentration: totalConcentration,
            morphology: totalMorphology,
            dna: totalDna,
            analysis: totalAnalysis
        )
        
        let previousOverall = (previousAverages.motility + previousAverages.concentration + previousAverages.morphology + previousAverages.dna + previousAverages.analysis) / (previousTests.count * 5)
        
        if currentOverall > previousOverall { return .up }
        if currentOverall < previousOverall { return .down }
        return .none
    }
    
    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical", "normal": return 80
        case "atypical", "abnormal": return 40
        default: return 50
        }
    }
}

// Overall Score Card with 3/4 Circular Gauge
struct OverallScoreCard: View {
    let overallScore: Int
    fileprivate let trend: Trend
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                // Background arc (3/4 circle, gap at bottom)
                Circle()
                    .trim(from: 0.5833, to: 0.4167) // 270-degree arc (210° to 150° counterclockwise)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(90)) // Rotate to position gap at bottom (180° center)
                
                // Progress arc (start from 7 o'clock = 0, fill clockwise to 5 o'clock = 100)
                Circle()
                    .trim(from: 0.5833 - (0.75 * CGFloat(overallScore) / 100), to: 0.5833) // Start at 210°, fill 270° clockwise to 150°
                    .stroke(
                        LinearGradient(
                            colors: scoreGradient(),
                            startPoint: .bottomTrailing, // Start at 7 o'clock (bottom right)
                            endPoint: .bottomLeading     // End at 5 o'clock (bottom left)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(90)) // Rotate to position gap at bottom
                    .animation(.easeInOut(duration: 0.5), value: overallScore)
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(overallScore)")
                        .font(.system(size: 48, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    
                    Text(overallScoreReference(score: overallScore))
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Overall score: \(overallScore) out of 100, \(overallScoreReference(score: overallScore))")
        }
        .padding()
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
    
    private func overallScoreReference(score: Int) -> String {
        switch score {
        case 80...100:
            return "In the Fertile Zone"
        case 60..<80:
            return "Needs Improvement"
        default:
            return "Below Average"
        }
    }
    
    private func scoreGradient() -> [Color] {
        // Darker green (score 0) to brighter green (score 100)
        return [
            Color(hex: "2E7D32"), // Darker green (forest green) at 7 o'clock
            Color(hex: "76FF03")   // Brighter green (lime green) at 5 o'clock
        ]
    }
}

// Fertility Status Section (No Dropdown)
struct FertilityStatusView: View {
    let motility: Int
    let concentration: Int
    let morphology: Int
    let dnaFragmentation: Int?
    let spermAnalysis: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            Text("Fertility Status")
                .font(.title3.bold())
                .fontDesign(.rounded)
                .foregroundColor(.black)
            
            // Categories
            CategoryRow(label: "Sperm Quality", score: spermAnalysis)
            CategoryRow(label: "Motility", score: motility)
            CategoryRow(label: "Concentration", score: concentration)
            CategoryRow(label: "Morphology", score: morphology)
            if let dnaFrag = dnaFragmentation {
                CategoryRow(label: "DNA Fragmentation", score: dnaFrag)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// Category Row for Fertility Status
struct CategoryRow: View {
    let label: String
    let score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title and Score
            HStack(alignment: .center, spacing: 12) {
                Text(label)
                    .font(.headline.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(score)")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
            }
            
            // Progress Bar (Stretches across the screen)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                GeometryReader { geometry in
                    Capsule()
                        .fill(scoreGradient(score: score))
                        .frame(width: max(geometry.size.width * CGFloat(score) / 100, 2), height: 8)
                        .animation(.easeOut(duration: 0.5), value: score)
                }
            }
            .frame(height: 8)
            
            // Status (on the left)
            Text(scoreFeedback(score: score))
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .accessibilityLabel("\(label): \(score) out of 100, \(scoreFeedback(score: score))")
    }
    
    func scoreGradient(score: Int) -> LinearGradient {
        if score >= 80 {
            return LinearGradient(colors: [Color(hex: "00D4B4"), Color(hex: "00D4B4").opacity(0.8)],
                                  startPoint: .leading, endPoint: .trailing)
        } else if score >= 60 {
            return LinearGradient(colors: [Color.yellow, Color.orange],
                                  startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color.red, Color.orange],
                                  startPoint: .leading, endPoint: .trailing)
        }
    }
    
    func scoreFeedback(score: Int) -> String {
        switch score {
        case 80...100:
            return "Optimal"
        case 60..<80:
            return "Needs Boosting"
        default:
            return "Low – Take Action"
        }
    }
}

struct PastResultsView: View {
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Past Results")
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                
                ForEach(testStore.tests, id: \.id) { test in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(test.dateFormatted)
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundColor(.black)
                        
                        let (score, label) = calculateOverallScore(test: test)
                        Text("Overall Score: \(score) – \(label)")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.gray)
                        
                        CategoryRow(label: "Sperm Quality", score: mapAnalysisStatusToScore(test.analysisStatus))
                        CategoryRow(label: "Motility", score: Int(test.totalMobility))
                        CategoryRow(label: "Concentration", score: Int(test.spermConcentration / 100 * 100))
                        CategoryRow(label: "Morphology", score: Int(test.morphologyRate))
                        if let dnaFrag = test.dnaFragmentationRisk {
                            CategoryRow(label: "DNA Fragmentation", score: Int(100 - Double(dnaFrag)))
                        }
                    }
                    .padding()
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.1), radius: 5)
                }
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Past Results")
    }
    
    private func calculateOverallScore(test: SpermTest) -> (Int, String) {
        let motilityScore = min(Int(test.totalMobility), 100)
        let concentrationScore = min(Int(test.spermConcentration / 100 * 100), 100)
        let morphologyScore = min(Int(test.morphologyRate), 100)
        let dnaScore = test.dnaFragmentationRisk.map { min(Int(100 - Double($0)), 100) } ?? 80
        let analysisScore = mapAnalysisStatusToScore(test.analysisStatus)
        
        let scores = [motilityScore, concentrationScore, morphologyScore, dnaScore, analysisScore]
        let average = scores.reduce(0, +) / scores.count
        
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
    
    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical", "normal": return 80
        case "atypical", "abnormal": return 40
        default: return 50
        }
    }
}

private func scoreColor(score: Int) -> Color {
    switch score {
    case 0..<50: return .red
    case 50..<70: return .orange
    case 70..<85: return .yellow
    case 85...100: return Color(hex: "00D4B4")
    default: return .black
    }
}

private enum Trend {
    case up, down, none
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension SpermTest {
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
            .environmentObject(TestStore())
    }
}
