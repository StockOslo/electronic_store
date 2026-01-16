//
//  Order.swift
//  Electronics store
//
//  Created by Erik Antonov on 09.01.2026.
//


import Foundation

struct Order: Identifiable, Decodable {
    let id: String
    let totalPrice: String
    let status: String
    let items: [OrderItem]

    enum CodingKeys: String, CodingKey {
        case id
        case totalPrice = "total_price"
        case status
        case items
    }
}

struct OrderItem: Identifiable, Decodable {
    let id: String
    let productId: String
    let quantity: Int
    let priceAtPurchase: String
    let product: ProductBrief?

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case quantity
        case priceAtPurchase = "price_at_purchase"
        case product
    }
}

struct ProductBrief: Decodable {
    let id: String
    let name: String
    let price: String
}