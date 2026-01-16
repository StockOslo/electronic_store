import SwiftUI

struct ProductCard: View {

    let product: Product
    let imageURLs: [String]

    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedImageIndex = 0

    private var fallbackSymbols: [String] { ["laptopcomputer", "laptopcomputer", "laptopcomputer"] }
    private var hasRemote: Bool { !imageURLs.isEmpty }
    private var displayImages: [String] { hasRemote ? imageURLs : fallbackSymbols }

    private var ratingValue: Double { Double(product.rating) ?? 0.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            TabView(selection: $selectedImageIndex) {
                ForEach(displayImages.indices, id: \.self) { index in
                    if hasRemote {
                        AsyncImage(url: URL(string: displayImages[index])) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            default:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .tag(index)
                    } else {
                        Image(systemName: displayImages[index])
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .foregroundStyle(.blue)
                            .tag(index)
                    }
                }
            }
            .frame(height: 140)
            .tabViewStyle(.page)

            HStack(alignment: .top) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                Button {
                    guard favoritesManager.isAuthorized else { return }
                    Task { await favoritesManager.toggleFavorite(productId: product.id) }
                } label: {
                    Image(systemName: favoritesManager.isFavorite(product.id) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(product.id) ? .red : .gray)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < Int(ratingValue) ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Text(String(format: "%.1f", ratingValue))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text("\(product.price) ₽")
                .font(.title3.bold())
                .foregroundStyle(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 6)
        )
        .onAppear {
            if hasRemote {
                ImagePrefetcher.shared.prefetch(imageURLs)
            }
        }
    }
}
