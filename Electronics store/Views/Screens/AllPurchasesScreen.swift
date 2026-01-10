import SwiftUI

struct AllPurchasesScreen: View {

    @EnvironmentObject private var ordersManager: OrdersManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Text("Все покупки")
                    .font(.largeTitle.bold())
                    .padding(.top, 12)

                if ordersManager.isLoading {
                    ProgressView().padding(.top, 20)
                } else if let err = ordersManager.errorMessage {
                    Text(err).foregroundColor(.red).padding(.top, 12)
                } else if ordersManager.allPurchasedItems.isEmpty {
                    Text("Покупок пока нет")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ForEach(ordersManager.allPurchasedItems, id: \.id) { item in
                        PurchasedItemCard(item: item)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await ordersManager.loadMyOrders()
        }
    }
}

struct PurchasedItemCard: View {
    let item: OrderItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Image(systemName: "shippingbox")
                    .foregroundStyle(.blue)

                Text(item.product?.name ?? "Товар")
                    .font(.headline)
                    .lineLimit(2)

                Spacer()
            }

            Text("Кол-во: \(item.quantity)")
                .foregroundColor(.gray)

            Text("Цена при покупке: \(item.priceAtPurchase) ₽")
                .font(.title3.bold())
                .foregroundStyle(.blue)

            // здесь можно добавить кнопку “Оставить отзыв”
            Button {
                // TODO: переход на экран отзывов
            } label: {
                Text("Оставить отзыв")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 4)
        )
    }
}