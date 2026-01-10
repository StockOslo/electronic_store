import Foundation

struct ProductSpec: Identifiable, Codable {
    let id: String
    let productId: String
    let specId: String
    let value: String
    var specName: String? // можно подставить имя характеристики из API, если возвращается
}

struct Review: Identifiable, Codable {
    let id: String
    let userName: String
    let date: String
    let rating: Int
    let reviewText: String
}

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
    let price: String
    let rating: Double
    let reviewCount: Int
    let images: [String]?
    let specs: [ProductSpec]?
}