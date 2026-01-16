import SwiftUI

struct FavoritesScreen: View {

    @StateObject private var productManager = ProductManager()
    @EnvironmentObject private var favoritesManager: FavoritesManager

    @State private var favoriteProducts: [Product] = []

    private let columns = [GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.red)

                    Text("favoriteLabel")
                        .font(.largeTitle.bold())

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    if !favoritesManager.isAuthorized {
                        VStack(spacing: 14) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.6))

                            Text("needAuthLabel")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)

                    } else if favoriteProducts.isEmpty && !favoritesManager.isLoading {
                        VStack(spacing: 14) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 56))
                                .foregroundColor(.gray.opacity(0.6))

                            Text("favoritesEmptyLabel")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)

                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(favoriteProducts) { product in
                                NavigationLink {
                                    ProductScreen(productId: product.id)
                                } label: {
                                    let urls = productManager.imagesByProductId[product.id] ?? []
                                    ProductCard(product: product, imageURLs: urls)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .background(Color.white)
            .task {
                await reloadFavoritesProducts()
            }
            .onChange(of: favoritesManager.favoriteIds) { _ in
                Task { await reloadFavoritesProducts() }
            }
        }
    }

    private func reloadFavoritesProducts() async {
        guard favoritesManager.isAuthorized else {
            favoriteProducts = []
            return
        }

        await favoritesManager.loadFavorites()
        let ids = Array(favoritesManager.favoriteIds)

        let loaded = await productManager.loadProductsByIds(ids)
        favoriteProducts = loaded

        productManager.products = loaded
        await productManager.prefetchImagesForLoadedProducts()
    }
}
