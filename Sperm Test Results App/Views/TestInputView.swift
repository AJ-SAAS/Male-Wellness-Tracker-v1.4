import SwiftUI

struct TestInputView: View {
    @State private var currentPage: Int = 1
    @State private var appearance: Appearance = .normal
    @State private var liquefaction: Liquefaction = .normal
    @State private var consistency: Consistency = .medium
    @State private var semenQuantity: Double = 2.0 // 0.0...10.0, step 0.1
    @State private var pH: Double = 7.4 // 0.0...14.0, step 0.1
    @State private var totalMobility: Double = 50.0 // 0...100, Slider
    @State private var progressiveMobility: Double = 40.0 // 0...100, Slider
    @State private var nonProgressiveMobility: Double = 10.0 // 0...100, Slider
    @State private var travelSpeed: Double = 0.1 // 0.0...1.0, step 0.01
    @State private var mobilityIndex: Double = 60.0 // 0...100, Slider
    @State private var still: Double = 30.0 // 0...100, Slider
    @State private var agglutination: Agglutination = .mild
    @State private var spermConcentration: Int = 20 // 0...100 M/mL
    @State private var totalSpermatozoa: Int = 40 // 0...200 M/mL
    @State private var functionalSpermatozoa: Int = 15 // 0...100 M/mL
    @State private var roundCells: Double = 0.5 // 0.0...10.0, step 0.1
    @State private var leukocytes: Double = 0.2 // 0.0...5.0, step 0.1
    @State private var liveSpermatozoa: Double = 70.0 // 0...100, Slider
    @State private var morphologyRate: Double = 5.0 // 0...100, Slider
    @State private var pathology: Double = 10.0 // 0...100, Slider
    @State private var headDefect: Double = 3.0 // 0...100, Slider
    @State private var neckDefect: Double = 2.0 // 0...100, Slider
    @State private var tailDefect: Double = 1.0 // 0...100, Slider
    @State private var estimateDNA: Bool = true
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if currentPage == 1 {
                        // Page 1: Analysis
                        Section(header: Text("Analysis")) {
                            Picker("Appearance", selection: $appearance) {
                                ForEach(Appearance.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized).tag($0)
                                }
                            }
                            Picker("Liquefaction", selection: $liquefaction) {
                                ForEach(Liquefaction.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized).tag($0)
                                }
                            }
                            Picker("Consistency", selection: $consistency) {
                                ForEach(Consistency.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized).tag($0)
                                }
                            }
                            Picker("Semen Quantity (mL)", selection: $semenQuantity) {
                                ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                    Text(String(format: "%.1f", $0)).tag($0)
                                }
                            }
                            Picker("pH", selection: $pH) {
                                ForEach(Array(stride(from: 0.0, through: 14.0, by: 0.1)), id: \.self) {
                                    Text(String(format: "%.1f", $0)).tag($0)
                                }
                            }
                        }
                    } else if currentPage == 2 {
                        // Page 2: Motility
                        Section(header: Text("Motility")) {
                            VStack(alignment: .leading) {
                                Text("Total Mobility: \(Int(totalMobility))%")
                                Slider(value: $totalMobility, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Progressive Mobility: \(Int(progressiveMobility))%")
                                Slider(value: $progressiveMobility, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Non-Progressive Mobility: \(Int(nonProgressiveMobility))%")
                                Slider(value: $nonProgressiveMobility, in: 0...100, step: 1)
                            }
                            Picker("Travel Speed (mm/sec)", selection: $travelSpeed) {
                                ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.01)), id: \.self) {
                                    Text(String(format: "%.2f", $0)).tag($0)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Mobility Index: \(Int(mobilityIndex))%")
                                Slider(value: $mobilityIndex, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Still: \(Int(still))%")
                                Slider(value: $still, in: 0...100, step: 1)
                            }
                            Picker("Agglutination", selection: $agglutination) {
                                ForEach(Agglutination.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized).tag($0)
                                }
                            }
                        }
                    } else if currentPage == 3 {
                        // Page 3: Concentration
                        Section(header: Text("Concentration")) {
                            Picker("Sperm Concentration (M/mL)", selection: $spermConcentration) {
                                ForEach(0...100, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            Picker("Total Spermatozoa (M/mL)", selection: $totalSpermatozoa) {
                                ForEach(0...200, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            Picker("Functional Spermatozoa (M/mL)", selection: $functionalSpermatozoa) {
                                ForEach(0...100, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            Picker("Round Cells (M/mL)", selection: $roundCells) {
                                ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                    Text(String(format: "%.1f", $0)).tag($0)
                                }
                            }
                            Picker("Leukocytes (M/mL)", selection: $leukocytes) {
                                ForEach(Array(stride(from: 0.0, through: 5.0, by: 0.1)), id: \.self) {
                                    Text(String(format: "%.1f", $0)).tag($0)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Live Spermatozoa: \(Int(liveSpermatozoa))%")
                                Slider(value: $liveSpermatozoa, in: 0...100, step: 1)
                            }
                        }
                    } else if currentPage == 4 {
                        // Page 4: Morphology
                        Section(header: Text("Morphology")) {
                            VStack(alignment: .leading) {
                                Text("Morphology Rate: \(Int(morphologyRate))%")
                                Slider(value: $morphologyRate, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Pathology: \(Int(pathology))%")
                                Slider(value: $pathology, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Head Defect: \(Int(headDefect))%")
                                Slider(value: $headDefect, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Neck Defect: \(Int(neckDefect))%")
                                Slider(value: $neckDefect, in: 0...100, step: 1)
                            }
                            VStack(alignment: .leading) {
                                Text("Tail Defect: \(Int(tailDefect))%")
                                Slider(value: $tailDefect, in: 0...100, step: 1)
                            }
                            Toggle("Estimate DNA Fragmentation Risk", isOn: $estimateDNA)
                        }
                    }
                }
                
                // Navigation Buttons
                HStack {
                    if currentPage > 1 {
                        Button("Back") {
                            currentPage -= 1
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .accessibilityLabel("Back to previous page")
                    }
                    
                    Spacer()
                    
                    if currentPage < 4 {
                        Button("Next") {
                            currentPage += 1
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Next page")
                    } else {
                        Button("Submit") {
                            submitTest()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Submit test results")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Test Results - Page \(currentPage)/4")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                    .accessibilityLabel("Cancel test input")
                }
            }
        }
    }
    
    private func submitTest() {
        var newTest = SpermTest(
            id: nil, // Firestore generates ID
            appearance: appearance,
            liquefaction: liquefaction,
            consistency: consistency,
            semenQuantity: semenQuantity,
            pH: pH,
            totalMobility: totalMobility,
            progressiveMobility: progressiveMobility,
            nonProgressiveMobility: nonProgressiveMobility,
            travelSpeed: travelSpeed,
            mobilityIndex: mobilityIndex,
            still: still,
            agglutination: agglutination,
            spermConcentration: Double(spermConcentration),
            totalSpermatozoa: Double(totalSpermatozoa),
            functionalSpermatozoa: Double(functionalSpermatozoa),
            roundCells: roundCells,
            leukocytes: leukocytes,
            liveSpermatozoa: liveSpermatozoa,
            morphologyRate: morphologyRate,
            pathology: pathology,
            headDefect: headDefect,
            neckDefect: neckDefect,
            tailDefect: tailDefect,
            date: Date()
        )
        
        if estimateDNA {
            newTest.estimateDNAFragmentation()
        }
        
        print("Submitting test: Appearance=\(newTest.appearance), SemenQuantity=\(newTest.semenQuantity), Date=\(newTest.date)")
        print("TestStore instance: \(testStore)")
        testStore.addTest(newTest)
        print("Dismissed TestInputView")
        dismiss()
    }
}

struct TestInputView_Previews: PreviewProvider {
    static var previews: some View {
        TestInputView()
            .environmentObject(TestStore())
    }
}
