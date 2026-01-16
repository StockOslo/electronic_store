import SwiftUI

struct AllPurchasesScreen: View {

    @EnvironmentObject private var ordersManager: OrdersManager

    private func shortOrderNumber(_ id: String) -> String {
        String(id.prefix(6)).uppercased()
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Text("allPurchasesTitle")
                    .font(.largeTitle.bold())
                    .padding(.top, 12)

                if ordersManager.isLoading {
                    ProgressView()
                        .padding(.top, 20)

                } else if let err = ordersManager.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding(.top, 12)

                } else if ordersManager.orders.isEmpty {
                    Text("noPurchasesLabel")
                        .foregroundColor(.gray)
                        .padding(.top, 20)

                } else {
                    ForEach(ordersManager.orders, id: \.id) { order in
                        let orderNum = shortOrderNumber(order.id)
                        let date = todayString()

                        ForEach(order.items, id: \.id) { item in
                            PurchaseCard(
                                title: item.product?.name ?? "",
                                orderNumber: orderNum,
                                date: date,
                                priceText: "\(item.priceAtPurchase) ₽",
                                iconName: "shippingbox",
                                productId: item.productId
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .scrollIndicators(.hidden)
        .task {
            await ordersManager.loadMyOrders()
        }
    }
}
