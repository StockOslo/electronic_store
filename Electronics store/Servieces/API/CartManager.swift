import Foundation
import SwiftUI

@MainActor
final class CartManager: ObservableObject {

    private let baseURL = "http://192.168.100.4:8000"

    @Published var items: [CartItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Чтобы экран показывал товары, а не только product_id:
    @Published var productsById: [String: Product] = [:]

    private let userManager: UserManager
    private let productManager = ProductManager()

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    var isAuthorized: Bool {
        (userManager.accessToken?.isEmpty == false)
    }

    // Кол-во товара в корзине
    func quantity(for productId: String) -> Int {
        items.first(where: { $0.productId == productId })?.quantity ?? 0
    }

    // MARK: - Public API

    func loadCart() async {
        guard isAuthorized else {
            items = []
            productsById = [:]
            return
        }

        guard let url = URL(string: "\(baseURL)/cart/cart") else { return }

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
                errorMessage = "Ошибка загрузки корзины (\(http.statusCode))"
                items = []
                productsById = [:]
                return
            }

            let cart = try JSONDecoder().decode(CartResponse.self, from: data)
            items = cart.items

            await hydrateProducts()

        } catch {
            print("❌ loadCart error:", error)
            errorMessage = "Не удалось загрузить корзину"
            items = []
            productsById = [:]
        }
    }

    // Установить точное количество (quantity >= 0)
    func setQuantity(productId: String, quantity: Int) async {
        guard isAuthorized else { return }

        if quantity <= 0 {
            await removeItem(productId: productId)
            return
        }

        await addOrUpdateItem(productId: productId, quantity: quantity)
    }

    func addOne(productId: String) async {
        let newQty = quantity(for: productId) + 1
        await setQuantity(productId: productId, quantity: newQty)
    }

    func removeOne(productId: String) async {
        let newQty = quantity(for: productId) - 1
        await setQuantity(productId: productId, quantity: newQty)
    }

    func clearCart() async {
        guard isAuthorized else { return }
        guard let url = URL(string: "\(baseURL)/cart/cart/clear") else { return }

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
                errorMessage = "Ошибка очистки корзины (\(http.statusCode))"
                return
            }

            items = []
            productsById = [:]
        } catch {
            print("❌ clearCart error:", error)
            errorMessage = "Не удалось очистить корзину"
        }
    }

    // MARK: - Private helpers

    private func addOrUpdateItem(productId: String, quantity: Int) async {
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

            let body = CartAddRequest(productId: productId, quantity: quantity)
            request.httpBody = try JSONEncoder().encode(body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "Ошибка обновления корзины (\(http.statusCode))"
                return
            }

            // после успешного запроса — перезагружаем корзину
            await loadCart()

        } catch {
            print("❌ addOrUpdateItem error:", error)
            errorMessage = "Не удалось обновить корзину"
        }
    }

    private func removeItem(productId: String) async {
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
                errorMessage = "Ошибка удаления из корзины (\(http.statusCode))"
                return
            }

            await loadCart()

        } catch {
            print("❌ removeItem error:", error)
            errorMessage = "Не удалось удалить товар"
        }
    }

    private func hydrateProducts() async {
        let ids = items.map { $0.productId }

        // грузим товары по одному (просто и надёжно)
        var dict: [String: Product] = [:]
        for id in ids {
            if let p = await productManager.fetchProduct(by: id) {
                dict[id] = p
            }
        }
        productsById = dict
    }
}