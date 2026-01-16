import Foundation
import SwiftUI
import Combine

@MainActor
final class CartManager: ObservableObject {

    private let baseURL = "http://172.20.10.2:8000"

    @Published var items: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var productsById: [String: Product] = [:]
    @Published var productImagesById: [String: [String]] = [:]

    private let userManager: UserManager
    private let productManager = ProductManager()
    private var cartRevision = 0

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    var isAuthorized: Bool {
        userManager.accessToken?.isEmpty == false
    }

    func quantity(for productId: String) -> Int {
        items.first(where: { $0.productId == productId })?.quantity ?? 0
    }

    func loadCart() async {
        guard isAuthorized else {
            items = []
            productsById = [:]
            productImagesById = [:]
            return
        }

        guard let url = URL(string: "\(baseURL)/cart/cart") else { return }

        cartRevision += 1
        let revision = cartRevision

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("Bearer \(userManager.accessToken!)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "cartLoadError"
                guard revision == cartRevision else { return }
                items = []
                productsById = [:]
                productImagesById = [:]
                return
            }

            let cart = try JSONDecoder().decode(CartResponse.self, from: data)
            guard revision == cartRevision else { return }

            items = cart.items

            await hydrateProducts(revision: revision)
            await hydrateImages(revision: revision)

        } catch {
            errorMessage = "cartLoadFailed"
            guard revision == cartRevision else { return }
            items = []
            productsById = [:]
            productImagesById = [:]
        }
    }

    func setQuantity(productId: String, quantity: Int) async {
        guard isAuthorized else { return }

        applyLocalQuantity(productId: productId, quantity: quantity)

        cartRevision += 1
        let revision = cartRevision

        if quantity <= 0 {
            await removeItemNetworkOnly(productId: productId, revision: revision)
        } else {
            await addOrUpdateItemNetworkOnly(productId: productId, quantity: quantity, revision: revision)
        }
    }

    func addOne(productId: String) async {
        await setQuantity(productId: productId, quantity: quantity(for: productId) + 1)
    }

    func removeOne(productId: String) async {
        await setQuantity(productId: productId, quantity: quantity(for: productId) - 1)
    }

    func clearCart() async {
        guard isAuthorized else { return }
        guard let url = URL(string: "\(baseURL)/cart/cart/clear") else { return }

        cartRevision += 1
        let revision = cartRevision

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("Bearer \(userManager.accessToken!)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "cartClearError"
                return
            }

            guard revision == cartRevision else { return }
            items = []
            productsById = [:]
            productImagesById = [:]

        } catch {
            errorMessage = "cartClearFailed"
        }
    }

    private func applyLocalQuantity(productId: String, quantity: Int) {
        if let idx = items.firstIndex(where: { $0.productId == productId }) {
            let existing = items[idx]
            if quantity <= 0 {
                items.remove(at: idx)
            } else {
                items[idx] = CartItem(id: existing.id, productId: productId, quantity: quantity)
            }
        } else if quantity > 0 {
            items.append(CartItem(id: UUID().uuidString, productId: productId, quantity: quantity))
        }
    }

    private func addOrUpdateItemNetworkOnly(productId: String, quantity: Int, revision: Int) async {
        guard let url = URL(string: "\(baseURL)/cart/cart/items") else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(userManager.accessToken!)", forHTTPHeaderField: "Authorization")

            request.httpBody = try JSONEncoder().encode(CartAddRequest(productId: productId, quantity: quantity))

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "cartUpdateError"
                if revision == cartRevision { await loadCart() }
            }

        } catch {
            errorMessage = "cartUpdateFailed"
            if revision == cartRevision { await loadCart() }
        }
    }

    private func removeItemNetworkOnly(productId: String, revision: Int) async {
        guard let url = URL(string: "\(baseURL)/cart/cart/items/\(productId)") else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("Bearer \(userManager.accessToken!)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "cartRemoveError"
                if revision == cartRevision { await loadCart() }
            }

        } catch {
            errorMessage = "cartRemoveFailed"
            if revision == cartRevision { await loadCart() }
        }
    }

    private func hydrateProducts(revision: Int) async {
        var dict: [String: Product] = [:]
        for id in items.map({ $0.productId }) {
            if let product = await productManager.fetchProduct(by: id) {
                dict[id] = product
            }
        }
        guard revision == cartRevision else { return }
        productsById = dict
    }

    private func hydrateImages(revision: Int) async {
        let ids = items.map { $0.productId }
        var result: [String: [String]] = [:]

        for productId in ids {
            guard let url = URL(string: "\(baseURL)/product-images/images/by-product/\(productId)") else { continue }

            do {
                let (data, resp) = try await URLSession.shared.data(from: url)
                let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
                guard (200...299).contains(code) else { continue }

                let decoded = try JSONDecoder().decode([ProductImage].self, from: data)
                let sorted = decoded.sorted {
                    if $0.sort_order != $1.sort_order { return $0.sort_order < $1.sort_order }
                    if $0.is_main != $1.is_main { return $0.is_main && !$1.is_main }
                    return $0.url < $1.url
                }
                let urls = sorted.map { $0.url }
                if !urls.isEmpty {
                    result[productId] = urls
                }
            } catch { }
        }

        guard revision == cartRevision else { return }
        productImagesById = result
    }
}
