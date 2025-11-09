import SwiftUI

struct ProductCard: View {
    // изображения (пока одинаковые, но можно подставить из API)
    let productImages = ["laptopcomputer", "laptopcomputer", "laptopcomputer"]
    
    var productName: String = "MacBook Pro M4"
    var productPrice: String = "145 000 руб."
    var productRating: Double = 4.5

    @State private var selectedImageIndex = 0
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Галерея изображений
            TabView(selection: $selectedImageIndex) {
                ForEach(productImages.indices, id: \.self) { index in
                    Image(systemName: productImages[index])
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundStyle(.blue)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            )
            
            // Название + сердечко
            HStack(alignment: .top) {
                Text(productName)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            // Рейтинг
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(productRating) ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.yellow)
                }
                Text(String(format: "%.1f", productRating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Цена
            Text(productPrice)
                .font(.title3)
                .bold()
                .foregroundStyle(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProductCard()
        .frame(width: 200)
}
