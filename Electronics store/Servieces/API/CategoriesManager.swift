import Foundation
import SwiftUI

@MainActor
final class CategoriesManager: ObservableObject {

    private let baseURL = "http://192.168.100.7:8000"

    @Published var categories: [CategoryDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func loadCategories() async {
        guard let url = URL(string: "\(baseURL)/categories/categories") else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else {
                errorMessage = "Ошибка сервера (\(code))"
                categories = []
                return
            }

            categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
        } catch {
            errorMessage = "Не удалось загрузить категории"
            categories = []
        }
    }
}