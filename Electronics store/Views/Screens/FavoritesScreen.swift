//
//  FavoritesScreen.swift
//  Electronics store
//
//  Created by Erik Antonov on 31.10.2025.
//

import SwiftUI

struct FavoritesScreen: View {
    private let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            
            
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("favoriteLabel")
                .font(.largeTitle)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ProductCard()
                    ProductCard()
                    ProductCard()
                    ProductCard()
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground))
        }.padding(.vertical, 20)
    }
}

#Preview {
    FavoritesScreen()
}
