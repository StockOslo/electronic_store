import SwiftUI

struct ProductScreen: View {

    let productId: String
    @StateObject private var productManager = ProductManager()

    @EnvironmentObject private var cartManager: CartManager

    @State private var showNeedAuthAlert = false
    @State private var goToCart = false

    private var inCartQty: Int {
        cartManager.quantity(for: productId)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                if let product = productManager.selectedProduct {

                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.name)
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    let urls = productManager.productImages.map { $0.url }
                    ProductCard(
                        product: product,
                        imageURLs: urls.isEmpty ? ["laptopcomputer", "laptopcomputer", "laptopcomputer"] : urls
                    )

                    if !productManager.specs.isEmpty {
                        CharacteristicsCard(
                            characteristics: productManager.specs.map {
                                (title: $0.spec_name, value: $0.value)
                            }
                        )
                    }

                    GradeCard(
                        rating: productManager.averageRating,
                        reviewCounts: productManager.ratingDistribution
                    )

                    if let last = productManager.lastReview {
                        ReviewCard(review: last)
                    } else {
                        Text("noReviewsLabel")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink {
                        ReviewsScreen(productId: product.id)
                    } label: {
                        Text("moreReviewsLabel")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray)
                            )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(isActive: $goToCart) {
                        ShoppingBagScreen()
                    } label: {
                        EmptyView()
                    }
                    .hidden()

                    if inCartQty > 0 {
                        Button {
                            goToCart = true
                        } label: {
                            Text("goToCartButton")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                )
                        }
                        .buttonStyle(.plain)

                    } else {
                        HStack(spacing: 12) {

                            Button {
                                guard cartManager.isAuthorized else {
                                    showNeedAuthAlert = true
                                    return
                                }
                                Task {
                                    await cartManager.loadCart()
                                    let current = cartManager.quantity(for: product.id)
                                    await cartManager.setQuantity(
                                        productId: product.id,
                                        quantity: current + 1
                                    )
                                }
                            } label: {
                                Text("bagBtnLabel")
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green)
                                    )
                            }
                            .buttonStyle(.plain)

                            Button {
                                guard cartManager.isAuthorized else {
                                    showNeedAuthAlert = true
                                    return
                                }
                                Task {
                                    await cartManager.loadCart()
                                    let current = cartManager.quantity(for: product.id)
                                    await cartManager.setQuantity(
                                        productId: product.id,
                                        quantity: current + 1
                                    )
                                    goToCart = true
                                }
                            } label: {
                                Text("buyBtnLabel")
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                } else {
                    ProgressView()
                        .padding(.top, 40)
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await productManager.loadProduct(by: productId)
            if cartManager.isAuthorized {
                await cartManager.loadCart()
            }
        }
        .alert("needAuthAlertTitle", isPresented: $showNeedAuthAlert) {
            Button("okButton", role: .cancel) {}
        }
    }
}
