import SwiftUI

struct ProductsFeedScreen: View {

    @StateObject private var productManager = ProductManager()
    @State private var selectedTag: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Рекомендации")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {

                            Button {
                                selectedTag = nil
                                Task { await productManager.loadProducts() }
                            } label: {
                                Text("allTag")
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(
                                            selectedTag == nil ? Color.accentColor : Color(.systemGray6)
                                        )
                                    )
                                    .foregroundColor(selectedTag == nil ? .white : .primary)
                            }
                            .buttonStyle(.plain)

                            ForEach(productManager.tags) { tag in
                                Button {
                                    selectedTag = tag.name
                                    Task { await productManager.loadProducts(by: tag.name) }
                                } label: {
                                    Text(tag.name)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule().fill(
                                                selectedTag == tag.name ? Color.accentColor : Color(.systemGray6)
                                            )
                                        )
                                        .foregroundColor(selectedTag == tag.name ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
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
                    .padding(.bottom, 16)
                }
            }
            .background(Color.white)
            .task {
                await productManager.loadTags()
                await productManager.loadProducts()
            }
        }
    }
}
