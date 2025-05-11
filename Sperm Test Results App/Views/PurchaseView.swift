import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Unlock Premium Features")
                .font(.title)
                .padding()

            if let offering = purchaseModel.currentOffering {
                ForEach(offering.availablePackages) { package in
                    Button(action: {
                        isPurchasing = true
                        purchaseModel.purchase(package: package)
                    }) {
                        HStack {
                            Text(package.storeProduct.localizedTitle)
                            Spacer()
                            Text(package.storeProduct.localizedPriceString)
                            if isPurchasing {
                                ProgressView()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isPurchasing)
                    .accessibilityLabel("Purchase \(package.storeProduct.localizedTitle)")
                }
            } else {
                Text("No offerings available")
                    .foregroundColor(.red)
                if let error = errorMessage ?? purchaseModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
                Button("Retry") {
                    purchaseModel.fetchOfferings()
                }
                .accessibilityLabel("Retry Fetching Offerings")
            }

            Button("Restore Purchases") {
                isPurchasing = true
                purchaseModel.restorePurchases()
            }
            .padding()
            .accessibilityLabel("Restore Purchases")

            Button("Close") {
                isPresented = false
            }
            .padding()
            .accessibilityLabel("Close Paywall")
        }
        .padding()
        .onAppear {
            purchaseModel.fetchOfferings()
            if purchaseModel.currentOffering == nil {
                errorMessage = purchaseModel.errorMessage ?? "Failed to load offerings"
            }
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView(isPresented: .constant(true), purchaseModel: PurchaseModel())
            .environmentObject(PurchaseModel())
    }
}
