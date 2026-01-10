import Foundation
import SwiftUI

@MainActor
final class FavoritesManager: ObservableObject {

    private let baseURL = "http://192.168.100.4:8000"

    // token берём так же, как в UserManager
    @AppStorage("access_token") private var accessToken: String?

    // Храним product_id избранных
    @Published private(set) var favoriteIds: Set<String> = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var isAuthorized: Bool { accessToken?.isEmpty == false }

    func isFavorite(_ productId: String) -> Bool {
        favoriteIds.contains(productId)
    }

    // MARK: - Load all favorites
    func loadFavorites() async {
        guard isAuthorized else {
            favoriteIds = []
            return
        }

        guard let url = URL(string: "\(baseURL)/favorites/favorites") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let http = response as? HTTPURLResponse

            guard http?.statusCode == 200 else {
                errorMessage = "Ошибка избранного: \(http?.statusCode ?? -1)"
                return
            }

            let items = try JSONDecoder().decode([FavoriteItem].self, from: data)
            favoriteIds = Set(items.map { $0.product_id })
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toggle favorite
    func toggleFavorite(productId: String) async {
        guard isAuthorized else {
            errorMessage = "Нужно войти в аккаунт"
            return
        }

        if isFavorite(productId) {
            await removeFavorite(productId: productId)
        } else {
            await addFavorite(productId: productId)
        }
    }

    // MARK: - Add
    private func addFavorite(productId: String) async {
        guard let url = URL(string: "\(baseURL)/favorites/favorites/\(productId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        // optimistic UI
        favoriteIds.insert(productId)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let http = response as? HTTPURLResponse
            if http?.statusCode != 201 && http?.statusCode != 200 {
                // rollback
                favoriteIds.remove(productId)
                errorMessage = "Не удалось добавить в избранное"
            }
        } catch {
            favoriteIds.remove(productId)
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Remove
    private func removeFavorite(productId: String) async {
        guard let url = URL(string: "\(baseURL)/favorites/favorites/\(productId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        // optimistic UI
        favoriteIds.remove(productId)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let http = response as? HTTPURLResponse
            if http?.statusCode != 200 {
                // rollback
                favoriteIds.insert(productId)
                errorMessage = "Не удалось удалить из избранного"
            }
        } catch {
            favoriteIds.insert(productId)
            errorMessage = error.localizedDescription
        }
    }
}