//
//  BagsProductCard.swift
//  Electronics store
//
//  Created by Erik Antonov on 02.11.2025.
//

import SwiftUI

struct BagsProductCard: View {
    let productImages = ["laptopcomputer", "laptopcomputer", "laptopcomputer"]
    
    var productName: String = "MacBook Pro M4"
    var productPrice: String = "145 000 ₽"
    var minValue: Int = 1
    var maxValue: Int = 99
    
    @State var quantity: Int = 1
    
    @State private var selectedImageIndex = 0
    @State private var isFavorite = false
    
    var body: some View {
        HStack( spacing: 8) {
            
            VStack(alignment:.leading, spacing:8){
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
                Text(productName)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            

            
            
            VStack(alignment: .leading, spacing: 5){
                // Цена
                Text(productPrice)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 32)
                HStack(spacing: 20) {
                    // Минус
                    Button(action: {
                        if quantity > minValue { quantity -= 1 }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    // Текущее количество
                    Text("\(quantity)")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 40)
                        .multilineTextAlignment(.center)
                    
                    // Плюс
                    Button(action: {
                        if quantity < maxValue { quantity += 1 }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.05))
                )
            }
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
    BagsProductCard()
}
