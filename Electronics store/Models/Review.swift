//
//  Review.swift
//  Electronics store
//
//  Created by Erik Antonov on 08.01.2026.
//


import Foundation


struct Review: Identifiable, Decodable {
    let id: String
    let userId: String?
    let productId: String?
    let rating: Int?
    let text: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case productId = "product_id"
        case rating
        case text
        case createdAt = "created_at"
    }
}
