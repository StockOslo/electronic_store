import Foundation
import SwiftUI
import Combine

struct FavoriteItem: Decodable {
    let product_id: String
}

@MainActor
final class FavoritesManager: ObservableObject {

    private let baseURL = "http://172.20.10.2:8000"

    @AppStorage("access_token") private var accessToken: String?

    @Published var favoriteIds: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isAuthorized: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }

    func isFavorite(_ productId: String) -> Bool {
        favoriteIds.contains(productId)
    }

    func toggleFavorite(productId: String) async {
        guard isAuthorized else {
            errorMessage = "authRequired"
            return
        }

        if isFavorite(productId) {
            await removeFavorite(productId: productId)
        } else {
            await addFavorite(productId: productId)
        }
    }

    func loadFavorites() async {
        guard isAuthorized else {
            favoriteIds = []
            return
        }

        guard let url = URL(string: "\(baseURL)/favorites/favorites") else {
            errorMessage = "invalidUrl"
            favoriteIds = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                errorMessage = "favoritesLoadError"
                return
            }

            let decoded = try JSONDecoder().decode([FavoriteItem].self, from: data)
            favoriteIds = Set(decoded.map { $0.product_id })

        } catch {
            errorMessage = "favoritesLoadFailed"
            favoriteIds = []
        }
    }

    private func addFavorite(productId: String) async {
        guard let url = URL(string: "\(baseURL)/favorites/favorites/\(productId)") else {
            errorMessage = "invalidUrl"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                errorMessage = "favoritesAddError"
                return
            }

            favoriteIds.insert(productId)

        } catch {
            errorMessage = "favoritesAddFailed"
        }
    }

    private func removeFavorite(productId: String) async {
        guard let url = URL(string: "\(baseURL)/favorites/favorites/\(productId)") else {
            errorMessage = "invalidUrl"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                errorMessage = "favoritesRemoveError"
                return
            }

            favoriteIds.remove(productId)

        } catch {
            errorMessage = "favoritesRemoveFailed"
        }
    }
}
