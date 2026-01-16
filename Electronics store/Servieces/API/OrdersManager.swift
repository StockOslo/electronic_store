import Foundation
import SwiftUI
import Combine

@MainActor
final class OrdersManager: ObservableObject {

    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "http://172.20.10.2:8000"
    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    private var token: String? { userManager.accessToken }

    func loadMyOrders() async {
        guard let token, !token.isEmpty else {
            orders = []
            errorMessage = nil
            return
        }

        guard let url = URL(string: "\(baseURL)/orders/orders") else {
            errorMessage = "invalidUrl"
            orders = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "accept")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, resp) = try await URLSession.shared.data(for: req)
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                errorMessage = "ordersLoadError"
                orders = []
                return
            }

            orders = try JSONDecoder().decode([Order].self, from: data)

        } catch {
            errorMessage = "ordersLoadFailed"
            orders = []
        }
    }

    func createOrderFromCart() async -> Order? {
        guard let token, !token.isEmpty else {
            errorMessage = "authRequired"
            return nil
        }

        guard let url = URL(string: "\(baseURL)/orders/orders") else {
            errorMessage = "invalidUrl"
            return nil
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "accept")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, resp) = try await URLSession.shared.data(for: req)
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? 0

            guard (200...299).contains(statusCode) else {
                if statusCode == 500 {
                    errorMessage = "orderNotCompleted"
                } else if let apiError = try? JSONDecoder().decode(APIError.self, from: data),
                          !apiError.detail.isEmpty {
                    errorMessage = apiError.detail
                } else {
                    errorMessage = "orderCreateError"
                }
                return nil
            }

            let order = try JSONDecoder().decode(Order.self, from: data)
            await loadMyOrders()
            return order

        } catch {
            errorMessage = "orderCreateFailed"
            return nil
        }
    }

    var allPurchasedItems: [OrderItem] {
        orders.flatMap { $0.items }
    }

    var lastOrder: Order? {
        orders.first
    }

    var lastPurchasedItem: OrderItem? {
        lastOrder?.items.first
    }
}
