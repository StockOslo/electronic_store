import Foundation

@MainActor
final class OrdersManager: ObservableObject {

    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let baseURL = "http://0.0.0.0:8000"   // или твой IP
    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    private var token: String? { userManager.accessToken }

    func loadMyOrders() async {
        guard let token, !token.isEmpty else {
            orders = []
            return
        }

        guard let url = URL(string: "\(baseURL)/orders/orders") else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "accept")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, resp) = try await URLSession.shared.data(for: req)

            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                errorMessage = "Ошибка загрузки заказов (\(http.statusCode))"
                return
            }

            orders = try JSONDecoder().decode([Order].self, from: data)

        } catch {
            errorMessage = "Не удалось загрузить заказы"
            print("❌ loadMyOrders error:", error)
        }
    }

    /// POST /orders/orders — создание заказа из корзины
    func createOrderFromCart() async -> Order? {
        guard let token, !token.isEmpty else { return nil }
        guard let url = URL(string: "\(baseURL)/orders/orders") else { return nil }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "accept")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, resp) = try await URLSession.shared.data(for: req)

            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                // полезно вытащить detail, но пока коротко
                errorMessage = "Ошибка создания заказа (\(http.statusCode))"
                return nil
            }

            let order = try JSONDecoder().decode(Order.self, from: data)
            // обновим список заказов (чтобы в аккаунте сразу появился)
            await loadMyOrders()
            return order

        } catch {
            errorMessage = "Не удалось создать заказ"
            print("❌ createOrderFromCart error:", error)
            return nil
        }
    }

    /// Удобно: все товары из всех заказов (плоским списком)
    var allPurchasedItems: [OrderItem] {
        orders.flatMap { $0.items }
    }

    /// Последний заказ (если API уже сортирует — ок; иначе можно самому отсортировать)
    var lastOrder: Order? { orders.first }

    /// Первый товар из последнего заказа (то, что надо для “Последняя покупка”)
    var lastPurchasedItem: OrderItem? { lastOrder?.items.first }
}