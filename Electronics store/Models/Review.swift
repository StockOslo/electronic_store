import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let rating: Int
    let text: String
    let created_at: String
}