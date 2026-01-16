import SwiftUI

struct PurchaseCard: View {

    
    var title: String
    var orderNumber: String
    var date: String
    var priceText: String
    var iconName: String = "laptopcomputer"

    
    var productId: String

    var body: some View {
        NavigationLink {
            CreateReviewScreen(productId: productId, productName: title)
        } label: {
            content
        }
        .buttonStyle(.plain)
    }

 
    private var content: some View {
        HStack(spacing: 14) {

            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text("Заказ №\(orderNumber)  \(date)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Text(priceText)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
}
