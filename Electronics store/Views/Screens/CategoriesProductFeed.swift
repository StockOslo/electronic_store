import SwiftUI

struct CategoriesProductFeed: View {

    let categoryId: String
    let categoryName: String

    @StateObject private var productManager = ProductManager()

    @State private var filters: [(title: String, options: [String])] = []
    @State private var isLoadingFilters = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Text(LocalizedStringKey(categoryName))
                        .font(.largeTitle.bold())
                }
                .padding(.horizontal, 20)

                ScrollView {
                    VStack {

                        CategoryFiltersCard(
                            filters: filters,
                            isLoading: isLoadingFilters,
                            onSelect: { specName, value in
                                Task {
                                    if let v = value, !v.isEmpty {
                                        await productManager.loadProductsBySpec(
                                            specName: specName,
                                            value: v
                                        )
                                    } else {
                                        await productManager.loadProductsByCategory(
                                            categoryId: categoryId
                                        )
                                    }
                                }
                            }
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(productManager.products) { product in
                                NavigationLink {
                                    ProductScreen(productId: product.id)
                                } label: {
                                    let urls = productManager.imagesByProductId[product.id] ?? []
                                    ProductCard(product: product, imageURLs: urls)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color.white)
        }
        .navigationTitle("")
        .task {
            await productManager.loadProductsByCategory(categoryId: categoryId)

            isLoadingFilters = true
            let dict = await productManager.buildFiltersForCategoryProducts(productManager.products)

            var arr: [(String, [String])] = dict.map { ($0.key, $0.value) }
            arr.sort { $0.0 < $1.0 }

            filters = arr
            isLoadingFilters = false
        }
    }
}
