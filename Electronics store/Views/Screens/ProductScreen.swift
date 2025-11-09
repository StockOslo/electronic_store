//
//  ProductScreen.swift
//  Electronics store
//
//  Created by Erik Antonov on 31.10.2025.
//
import SwiftUI

struct ProductScreen: View {
    private let columns = [
        GridItem(.flexible())
    ]
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ProductCard()
                    CharacteristicsCard()
                    GradeCard()
                    ReviewCard()
                    Button(action: {
                    }) {
                        Text("moreReviewsLabel")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 0)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray)
                                    .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    
                    
                    
                    HStack{
                        Button(action: {
                        }) {
                            Text("bagBtnLabel")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 0)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                        }) {
                            Text("buyBtnLabel")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 0)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        
                        
                        
                    }
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground))
        }.padding(.vertical, 20)
    }
}

#Preview {
    ProductScreen()
}
