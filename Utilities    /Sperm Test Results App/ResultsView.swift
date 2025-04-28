import SwiftUI

struct ResultsView: View {
    let test: SpermTest
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detailed Wellness Metrics")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .padding(.bottom)
                
                // Analysis
                StatusBox(title: "Appearance", status: test.appearance.rawValue.capitalized)
                StatusBox(title: "Liquefaction", status: test.liquefaction.rawValue.capitalized)
                StatusBox(title: "Consistency", status: test.consistency.rawValue.capitalized)
                StatusBox(title: "Semen Quantity", status: String(format: "%.1f mL", test.semenQuantity))
                StatusBox(title: "pH", status: String(format: "%.1f", test.pH))
                
                // Motility
                StatusBox(title: "Total Mobility", status: String(format: "%.0f%%", test.totalMobility))
                StatusBox(title: "Progressive Mobility", status: String(format: "%.0f%%", test.progressiveMobility))
                StatusBox(title: "Non-Progressive Mobility", status: String(format: "%.0f%%", test.nonProgressiveMobility))
                StatusBox(title: "Travel Speed", status: String(format: "%.2f mm/sec", test.travelSpeed))
                StatusBox(title: "Mobility Index", status: String(format: "%.0f%%", test.mobilityIndex))
                StatusBox(title: "Still", status: String(format: "%.0f%%", test.still))
                StatusBox(title: "Agglutination", status: test.agglutination.rawValue.capitalized)
                
                // Concentration
                StatusBox(title: "Sperm Concentration", status: String(format: "%.0f M/mL", test.spermConcentration))
                StatusBox(title: "Total Spermatozoa", status: String(format: "%.0f M/mL", test.totalSpermatozoa))
                StatusBox(title: "Functional Spermatozoa", status: String(format: "%.0f M/mL", test.functionalSpermatozoa))
                StatusBox(title: "Round Cells", status: String(format: "%.1f M/mL", test.roundCells))
                StatusBox(title: "Leukocytes", status: String(format: "%.1f M/mL", test.leukocytes))
                StatusBox(title: "Live Spermatozoa", status: String(format: "%.0f%%", test.liveSpermatozoa))
                
                // Morphology
                StatusBox(title: "Morphology Rate", status: String(format: "%.0f%%", test.morphologyRate))
                StatusBox(title: "Pathology", status: String(format: "%.0f%%", test.pathology))
                StatusBox(title: "Head Defect", status: String(format: "%.0f%%", test.headDefect))
                StatusBox(title: "Neck Defect", status: String(format: "%.0f%%", test.neckDefect))
                StatusBox(title: "Tail Defect", status: String(format: "%.0f%%", test.tailDefect))
                
                // DNA Fragmentation
                if let dnaRisk = test.dnaFragmentationRisk, let category = test.dnaRiskCategory {
                    StatusBox(title: "DNA Fragmentation Risk", status: "\(dnaRisk)% (\(category))")
                    Text("Note: This is an estimate based on your inputs. Consult a doctor for accurate tests (e.g., SCD/TUNEL).")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                // Overall
                StatusBox(title: "Overall Status", status: test.overallStatus)
                
                Text("Results are for personal awareness, not medical diagnosis.")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Wellness Results")
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(test: SpermTest(
            appearance: .normal,
            liquefaction: .normal,
            consistency: .medium,
            semenQuantity: 2.0,
            pH: 7.4,
            totalMobility: 50.0,
            progressiveMobility: 40.0,
            nonProgressiveMobility: 10.0,
            travelSpeed: 0.1,
            mobilityIndex: 60.0,
            still: 30.0,
            agglutination: .mild,
            spermConcentration: 20.0,
            totalSpermatozoa: 40.0,
            functionalSpermatozoa: 15.0,
            roundCells: 0.5,
            leukocytes: 0.2,
            liveSpermatozoa: 70.0,
            morphologyRate: 5.0,
            pathology: 10.0,
            headDefect: 3.0,
            neckDefect: 2.0,
            tailDefect: 1.0,
            date: Date(),
            dnaFragmentationRisk: 10,
            dnaRiskCategory: "Low"
        ))
    }
}
