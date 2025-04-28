import Foundation

enum Appearance: String, Codable, CaseIterable { case normal, abnormal }
enum Liquefaction: String, Codable, CaseIterable { case normal, abnormal }
enum Consistency: String, Codable, CaseIterable { case thin, medium, thick }
enum Agglutination: String, Codable, CaseIterable { case mild, moderate, severe }

struct SpermTest: Identifiable, Codable {
    let id: UUID
    // Sperm Analysis
    let appearance: Appearance
    let liquefaction: Liquefaction
    let consistency: Consistency
    let semenQuantity: Double // mL
    let pH: Double // 0–14
    // Sperm Motility
    let totalMobility: Double // %
    let progressiveMobility: Double // %
    let nonProgressiveMobility: Double // %
    let travelSpeed: Double // mm/sec
    let mobilityIndex: Double // %
    let still: Double // %
    let agglutination: Agglutination
    // Sperm Concentration
    let spermConcentration: Double // million/mL
    let totalSpermatozoa: Double // million/mL
    let functionalSpermatozoa: Double // million/mL
    let roundCells: Double // million/mL
    let leukocytes: Double // million/mL
    let liveSpermatozoa: Double // %
    // Sperm Morphology
    let morphologyRate: Double // %
    let pathology: Double // %
    let headDefect: Double // %
    let neckDefect: Double // %
    let tailDefect: Double // %
    let date: Date
    // DNA Fragmentation (New)
    var dnaFragmentationRisk: Int? // Estimated risk (0-100%)
    var dnaRiskCategory: String?   // "Low"/"Moderate"/"High"

    enum CodingKeys: String, CodingKey {
        case id
        case appearance
        case liquefaction
        case consistency
        case semenQuantity
        case pH
        case totalMobility
        case progressiveMobility
        case nonProgressiveMobility
        case travelSpeed
        case mobilityIndex
        case still
        case agglutination
        case spermConcentration
        case totalSpermatozoa
        case functionalSpermatozoa
        case roundCells
        case leukocytes
        case liveSpermatozoa
        case morphologyRate
        case pathology
        case headDefect
        case neckDefect
        case tailDefect
        case date
        case dnaFragmentationRisk
        case dnaRiskCategory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        appearance = try container.decode(Appearance.self, forKey: .appearance)
        liquefaction = try container.decode(Liquefaction.self, forKey: .liquefaction)
        consistency = try container.decode(Consistency.self, forKey: .consistency)
        semenQuantity = try container.decode(Double.self, forKey: .semenQuantity)
        pH = try container.decode(Double.self, forKey: .pH)
        totalMobility = try container.decode(Double.self, forKey: .totalMobility)
        progressiveMobility = try container.decode(Double.self, forKey: .progressiveMobility)
        nonProgressiveMobility = try container.decode(Double.self, forKey: .nonProgressiveMobility)
        travelSpeed = try container.decode(Double.self, forKey: .travelSpeed)
        mobilityIndex = try container.decode(Double.self, forKey: .mobilityIndex)
        still = try container.decode(Double.self, forKey: .still)
        agglutination = try container.decode(Agglutination.self, forKey: .agglutination)
        spermConcentration = try container.decode(Double.self, forKey: .spermConcentration)
        totalSpermatozoa = try container.decode(Double.self, forKey: .totalSpermatozoa)
        functionalSpermatozoa = try container.decode(Double.self, forKey: .functionalSpermatozoa)
        roundCells = try container.decode(Double.self, forKey: .roundCells)
        leukocytes = try container.decode(Double.self, forKey: .leukocytes)
        liveSpermatozoa = try container.decode(Double.self, forKey: .liveSpermatozoa)
        morphologyRate = try container.decode(Double.self, forKey: .morphologyRate)
        pathology = try container.decode(Double.self, forKey: .pathology)
        headDefect = try container.decode(Double.self, forKey: .headDefect)
        neckDefect = try container.decode(Double.self, forKey: .neckDefect)
        tailDefect = try container.decode(Double.self, forKey: .tailDefect)
        date = try container.decode(Date.self, forKey: .date)
        dnaFragmentationRisk = try container.decodeIfPresent(Int.self, forKey: .dnaFragmentationRisk)
        dnaRiskCategory = try container.decodeIfPresent(String.self, forKey: .dnaRiskCategory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(liquefaction, forKey: .liquefaction)
        try container.encode(consistency, forKey: .consistency)
        try container.encode(semenQuantity, forKey: .semenQuantity)
        try container.encode(pH, forKey: .pH)
        try container.encode(totalMobility, forKey: .totalMobility)
        try container.encode(progressiveMobility, forKey: .progressiveMobility)
        try container.encode(nonProgressiveMobility, forKey: .nonProgressiveMobility)
        try container.encode(travelSpeed, forKey: .travelSpeed)
        try container.encode(mobilityIndex, forKey: .mobilityIndex)
        try container.encode(still, forKey: .still)
        try container.encode(agglutination, forKey: .agglutination)
        try container.encode(spermConcentration, forKey: .spermConcentration)
        try container.encode(totalSpermatozoa, forKey: .totalSpermatozoa)
        try container.encode(functionalSpermatozoa, forKey: .functionalSpermatozoa)
        try container.encode(roundCells, forKey: .roundCells)
        try container.encode(leukocytes, forKey: .leukocytes)
        try container.encode(liveSpermatozoa, forKey: .liveSpermatozoa)
        try container.encode(morphologyRate, forKey: .morphologyRate)
        try container.encode(pathology, forKey: .pathology)
        try container.encode(headDefect, forKey: .headDefect)
        try container.encode(neckDefect, forKey: .neckDefect)
        try container.encode(tailDefect, forKey: .tailDefect)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(dnaFragmentationRisk, forKey: .dnaFragmentationRisk)
        try container.encodeIfPresent(dnaRiskCategory, forKey: .dnaRiskCategory)
    }

    init(
        appearance: Appearance,
        liquefaction: Liquefaction,
        consistency: Consistency,
        semenQuantity: Double,
        pH: Double,
        totalMobility: Double,
        progressiveMobility: Double,
        nonProgressiveMobility: Double,
        travelSpeed: Double,
        mobilityIndex: Double,
        still: Double,
        agglutination: Agglutination,
        spermConcentration: Double,
        totalSpermatozoa: Double,
        functionalSpermatozoa: Double,
        roundCells: Double,
        leukocytes: Double,
        liveSpermatozoa: Double,
        morphologyRate: Double,
        pathology: Double,
        headDefect: Double,
        neckDefect: Double,
        tailDefect: Double,
        date: Date,
        dnaFragmentationRisk: Int? = nil,
        dnaRiskCategory: String? = nil
    ) {
        self.id = UUID()
        self.appearance = appearance
        self.liquefaction = liquefaction
        self.consistency = consistency
        self.semenQuantity = semenQuantity
        self.pH = pH
        self.totalMobility = totalMobility
        self.progressiveMobility = progressiveMobility
        self.nonProgressiveMobility = nonProgressiveMobility
        self.travelSpeed = travelSpeed
        self.mobilityIndex = mobilityIndex
        self.still = still
        self.agglutination = agglutination
        self.spermConcentration = spermConcentration
        self.totalSpermatozoa = totalSpermatozoa
        self.functionalSpermatozoa = functionalSpermatozoa
        self.roundCells = roundCells
        self.leukocytes = leukocytes
        self.liveSpermatozoa = liveSpermatozoa
        self.morphologyRate = morphologyRate
        self.pathology = pathology
        self.headDefect = headDefect
        self.neckDefect = neckDefect
        self.tailDefect = tailDefect
        self.date = date
        self.dnaFragmentationRisk = dnaFragmentationRisk
        self.dnaRiskCategory = dnaRiskCategory
    }

    var analysisStatus: String {
        if appearance == .normal && liquefaction == .normal && pH >= 7.2 && pH <= 8.0 && semenQuantity >= 1.5 {
            return "Typical"
        }
        return "Atypical"
    }

    var motilityStatus: String {
        if totalMobility >= 40 && progressiveMobility >= 32 && agglutination == .mild {
            return "Active"
        }
        return "Less Active"
    }

    var concentrationStatus: String {
        if spermConcentration >= 15 && liveSpermatozoa >= 58 {
            return "Typical"
        }
        return "Lower"
    }

    var morphologyStatus: String {
        if morphologyRate >= 4 {
            return "Typical"
        }
        return "Varied"
    }

    var overallStatus: String {
        if analysisStatus == "Typical" && motilityStatus == "Active" && concentrationStatus == "Typical" && morphologyStatus == "Typical" {
            return "Balanced"
        }
        return "Review"
    }

    mutating func estimateDNAFragmentation() {
        let weights: [String: Double] = [
            "low_mobility": 0.30,    // totalMobility <40%
            "abnormal_morph": 0.25,  // morphologyRate <4%
            "high_leukocytes": 0.20, // leukocytes >1M/mL
            "low_volume": 0.15,      // semenQuantity <1.5mL
            "abnormal_ph": 0.10      // pH <7.2 or >8.0
        ]
        
        var riskScore: Double = 0
        var flags: [String] = []
        
        if totalMobility < 40 {
            riskScore += weights["low_mobility"]!
            flags.append("low motility")
        }
        if morphologyRate < 4 {
            riskScore += weights["abnormal_morph"]!
            flags.append("abnormal morphology")
        }
        if leukocytes > 1 {
            riskScore += weights["high_leukocytes"]!
            flags.append("high leukocytes")
        }
        if semenQuantity < 1.5 {
            riskScore += weights["low_volume"]!
            flags.append("low semen volume")
        }
        if pH < 7.2 || pH > 8.0 {
            riskScore += weights["abnormal_ph"]!
            flags.append("abnormal pH")
        }
        
        let estimatedRisk = min(Int(riskScore * 100), 100)
        self.dnaFragmentationRisk = estimatedRisk
        self.dnaRiskCategory = estimatedRisk < 20 ? "Low" : (estimatedRisk < 40 ? "Moderate" : "High")
    }
}
