import SwiftUI

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
                .foregroundColor(colorForStatus(status))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status: \(status)")
    }

    private func colorForStatus(_ status: String) -> Color {
        let lowercasedStatus = status.lowercased()
        if lowercasedStatus.contains("normal") ||
           lowercasedStatus.contains("typical") ||
           lowercasedStatus.contains("active") ||
           lowercasedStatus.contains("mild") ||
           lowercasedStatus.contains("balanced") {
            return .green
        }
        return .orange
    }
}
