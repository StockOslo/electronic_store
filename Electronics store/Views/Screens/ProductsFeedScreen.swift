import SwiftUI

struct ProductsFeedScreen: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ProductCard()
                ProductCard()
                ProductCard()
                ProductCard()
            }
            .padding(10)
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    ProductsFeedScreen()
}
