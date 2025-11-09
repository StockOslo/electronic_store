//
//  CategoriesScreen.swift
//  Electronics store
//
//  Created by Erik Antonov on 04.11.2025.
//

import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: LocalizedStringKey
    let image: String
}

struct CategoriesScreen: View {
    // Пример категорий — можно потом заменить на свои
    let categories = [
        Category(name: "laptops", image: "laptopcomputer"),
        Category(name: "smartphones", image: "iphone"),
        Category(name: "tablets", image: "ipad"),
        Category(name: "accessories", image: "headphones"),
        Category(name: "tvs", image: "tv"),
        Category(name: "consoles", image: "gamecontroller")
    ]
    
    // Макет сетки
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Заголовок
                Text("categoryLabel")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal, 20)
                
                // Сетка карточек
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categories) { category in
                        Button {
                            // TODO: переход на экран категории
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: category.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                                    .foregroundStyle(.blue)
                                
                                Text(category.name)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    CategoriesScreen()
}
