//
//  CategoriesProductFeed.swift
//  Electronics store
//
//  Created by Erik Antonov on 04.11.2025.
//

import SwiftUI

struct CategoriesProductFeed: View {

    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            VStack(spacing: 16) {
                // Верхняя панель
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    
                    Text("categoryNameLabel")
                        .font(.largeTitle)
                        .bold()
                    
                    
                }
                .padding(.horizontal, 20)
                ScrollView {
                    VStack{
                        CategoryFiltersCard()
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(0..<10, id: \.self) { _ in
                                ProductCard()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
                
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    CategoriesProductFeed()
}
