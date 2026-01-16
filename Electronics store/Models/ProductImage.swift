import Foundation

struct ProductImage: Decodable, Identifiable {
    let id: String
    let product_id: String
    let url: String
    let sort_order: Int
    let is_main: Bool
}