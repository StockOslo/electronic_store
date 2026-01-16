//
//  Product.swift
//  Electronics store
//
//  Created by Erik Antonov on 06.01.2026.
//
import Foundation

struct Product: Identifiable, Decodable {
    let id: String
    let categoryId: String
    let name: String
    let description: String?
    let price: String
    let rating: String
    let reviewCount: Int

    // опционально на будущее (когда добавишь в API)
    let images: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case name
        case description
        case price
        case rating
        case reviewCount = "review_count"
        case images
    }
}
