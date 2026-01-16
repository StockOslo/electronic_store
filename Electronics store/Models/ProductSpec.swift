//
//  ProductSpec.swift
//  Electronics store
//
//  Created by Erik Antonov on 08.01.2026.
//


import Foundation


struct ProductSpec: Codable, Identifiable {
    let id: String
    let product_id: String
    let spec_id: String
    let value: String
    let spec_name: String
}
