//
//  PurchaseCard.swift
//  Electronics store
//
//  Created by Erik Antonov on 05.11.2025.
//

import SwiftUI

struct PurchaseCard: View {

    var title: String
    var orderNumber: String
    var date: String
    var iconName: String = "laptopcomputer"  

    var body: some View {
        HStack(spacing: 14) {
            // 🖼 Иконка товара
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            // 🧾 Информация о товаре
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Заказ №\(orderNumber) • \(date)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        PurchaseCard(
            title: "MacBook Air M3",
            orderNumber: "12345",
            date: "02.11.2025",
            iconName: "laptopcomputer"
        )
        
        PurchaseCard(
            title: "iPhone 15 Pro",
            orderNumber: "12346",
            date: "28.10.2025",
            iconName: "iphone"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
