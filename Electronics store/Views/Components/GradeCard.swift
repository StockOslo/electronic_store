//
//  GradeCard.swift
//  Electronics store
//
//  Created by Erik Antonov on 03.11.2025.
//

import SwiftUI

struct GradeCard: View {
    var rating: Double = 3.2
    var reviewCounts: [Int] = [120, 80, 40, 20, 10] 
    
    var maxCount: Int {
        reviewCounts.max() ?? 1
    }
    
    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 18) {
                
                HStack {
                    Text("ratingLabel")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating.rounded(.down)) ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.yellow)
                        }
                        
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // ⭐️ Распределение отзывов
                VStack(alignment: .leading, spacing: 8) {
                    ForEach((1...5).reversed(), id: \.self) { stars in
                        HStack {
                            HStack(spacing: 2) {
                                ForEach(0..<stars, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.yellow)
                                }
                            }
                            .frame(width: 60, alignment: .leading)
                            

                            GeometryReader { geo in
                                let widthRatio = CGFloat(reviewCounts[5 - stars]) / CGFloat(maxCount)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.yellow.opacity(0.8))
                                        .frame(width: geo.size.width * widthRatio, height: 4)
                                }
                            }
                            .frame(height: 10)
                            
                        }
                    }
                }
                
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    GradeCard()
}
