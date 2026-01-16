//
//  CartItem.swift
//  Electronics store
//
//  Created by Erik Antonov on 09.01.2026.
//


import Foundation

struct CartItem: Decodable, Identifiable, Equatable {
    let id: String
    let productId: String
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case quantity
    }
}

struct CartResponse: Decodable {
    let userId: String
    let items: [CartItem]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case items
    }
}

struct CartAddRequest: Encodable {
    let productId: String
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case quantity
    }
}
