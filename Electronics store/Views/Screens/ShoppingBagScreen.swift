import SwiftUI

struct ShoppingBagScreen: View {

    @EnvironmentObject private var cartManager: CartManager
    @EnvironmentObject private var ordersManager: OrdersManager

    private let columns = [GridItem(.flexible())]

    @State private var showSuccessAlert = false
    @State private var errorText: String? = nil

    @State private var promoCode: String = ""
    @State private var address: String = ""
    @State private var selectedPayMethod: String = ""

    private func priceToDouble(_ price: String) -> Double {
        let trimmed = price.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet(charactersIn: "0123456789., ")
        let filtered = String(trimmed.unicodeScalars.filter { allowed.contains($0) })
        let noSpaces = filtered.replacingOccurrences(of: " ", with: "")
        let normalized = noSpaces.replacingOccurrences(of: ",", with: ".")
        return Double(normalized) ?? 0
    }

    private func moneyText(_ value: Double) -> String {
        String(format: "%.2f ₽", value)
    }

    private var totalPrice: Double {
        cartManager.items.reduce(0) { sum, item in
            guard let product = cartManager.productsById[item.productId] else { return sum }
            return sum + priceToDouble(product.price) * Double(item.quantity)
        }
    }

    private var canCheckout: Bool {
        cartManager.isAuthorized && !cartManager.items.isEmpty && !ordersManager.isLoading && !cartManager.isLoading
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.blue)

                    Text("bagLabel")
                        .font(.largeTitle.bold())

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {

                        if !cartManager.isAuthorized {
                            VStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 42))
                                    .foregroundColor(.gray.opacity(0.7))

                                Text("needAuthLabel")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 34)

                        } else if cartManager.items.isEmpty && !cartManager.isLoading {
                            VStack(spacing: 10) {
                                Image(systemName: "cart.badge.minus")
                                    .font(.system(size: 44))
                                    .foregroundColor(.gray.opacity(0.7))

                                Text("bagEmptyLabel")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 34)

                        } else {
                            ForEach(cartManager.items, id: \.id) { item in
                                if let product = cartManager.productsById[item.productId] {
                                    BagsProductCard(
                                        product: product,
                                        imageURLs: cartManager.productImagesById[product.id] ?? []
                                    )
                                }
                            }

                            OrderSummaryCard(
                                promoCode: $promoCode,
                                address: $address,
                                selectedPayMethod: $selectedPayMethod
                            )

                            HStack {
                                Text("totalLabel")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.gray)

                                Spacer()

                                Text(moneyText(totalPrice))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.blue)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .padding(.horizontal, 6)
                            .padding(.top, 4)

                            Button {
                                Task { await checkout() }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .frame(height: 48)
                                        .opacity(canCheckout ? 1.0 : 0.6)

                                    if ordersManager.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("goToBuyLabel")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!canCheckout)
                            .padding(.top, 6)
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color.white)
        }
        .task {
            await cartManager.loadCart()
        }
        .alert("orderCreatedTitle", isPresented: $showSuccessAlert) {
            Button("okButton", role: .cancel) {}
        }
        .alert("errorTitle", isPresented: Binding(
            get: { errorText != nil },
            set: { _ in errorText = nil }
        )) {
            Button("okButton", role: .cancel) {}
        } message: {
            Text(errorText ?? "")
        }
    }

    private func checkout() async {
        guard cartManager.isAuthorized else { return }
        guard !cartManager.items.isEmpty else { return }

        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAddress.isEmpty else { return }
        guard !selectedPayMethod.isEmpty else { return }

        let created = await ordersManager.createOrderFromCart()

        if created != nil {
            await cartManager.loadCart()
            await ordersManager.loadMyOrders()
            showSuccessAlert = true
        } else {
            errorText = ordersManager.errorMessage ?? NSLocalizedString("orderCreateFailedLabel", comment: "")
        }
    }
}
