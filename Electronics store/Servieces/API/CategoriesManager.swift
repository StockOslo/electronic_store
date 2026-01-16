import Foundation
import SwiftUI
import Combine

@MainActor
final class CategoriesManager: ObservableObject {

    private let baseURL = "http://172.20.10.2:8000"

    @Published var categories: [CategoryDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCategories() async {
        guard let url = URL(string: "\(baseURL)/categories/categories") else {
            errorMessage = "invalidUrl"
            categories = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                errorMessage = "categoriesLoadError"
                categories = []
                return
            }

            categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
        } catch {
            errorMessage = "categoriesLoadFailed"
            categories = []
        }
    }
}
