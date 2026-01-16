//
//  CategoryDTO.swift
//  Electronics store
//
//  Created by Erik Antonov on 10.01.2026.
//


import Foundation

struct CategoryDTO: Identifiable, Decodable {
    let id: String
    let name: String
    let systemImageName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case systemImageName = "system_image_name"
    }
}