//
//  ReviewCard.swift
//  Electronics store
//
//  Created by Erik Antonov on 03.11.2025.
//

import SwiftUI

struct ReviewCard: View {
    var username: String = "Иван Петров"
       var date: String = "2 ноября 2025"
       var rating: Int = 4
       var reviewText: String = "Отличный ноутбук! Работает быстро, батареи хватает почти на целый день. Качество сборки на высоте, рекомендую."
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
                   
                   // 🔹 Верхняя часть — аватарка и имя
                   HStack(alignment: .center, spacing: 12) {
                       Image(systemName: "laptop")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 42, height: 42)
                           .padding(8)
                           .background(Color.gray.opacity(0.1))
                           .clipShape(Circle())
                       
                       VStack(alignment: .leading, spacing: 2) {
                           Text(username)
                               .font(.system(size: 16, weight: .semibold))
                               .foregroundColor(.primary)
                           Text(date)
                               .font(.system(size: 13))
                               .foregroundColor(.gray)
                       }
                       Spacer()
                   }
                   
                   // ⭐️ Рейтинг
                   HStack(spacing: 3) {
                       ForEach(0..<5) { index in
                           Image(systemName: index < rating ? "star.fill" : "star")
                               .resizable()
                               .frame(width: 13, height: 13)
                               .foregroundColor(.yellow)
                       }
                   }
                   
                   // 💬 Текст отзыва
                   Text(reviewText)
                       .font(.system(size: 15))
                       .foregroundColor(.gray)
                       .lineSpacing(4)
                   
               }
               .padding(18)
               .background(
                   RoundedRectangle(cornerRadius: 16)
                       .fill(Color.white)
                       .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
               )
           }
       }

#Preview {
    ReviewCard()
}
