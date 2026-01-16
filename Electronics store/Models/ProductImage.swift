//
//  ProductImage.swift
//  Electronics store
//
//  Created by Erik Antonov on 11.01.2026.
//


import Foundation

struct ProductImage: Decodable, Identifiable {
    let id: String
    let product_id: String
    let url: String
    let sort_order: Int
    let is_main: Bool
}