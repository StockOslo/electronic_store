import Foundation
import Combine
import SwiftUI

@MainActor
final class ProductManager: ObservableObject {

    private let baseURL = "http://172.20.10.2:8000"

    @Published var products: [Product] = []
    @Published var tags: [Tag] = []

    @Published var selectedProduct: Product?
    @Published var specs: [ProductSpec] = []
    @Published var reviews: [Review] = []
    @Published var averageRating: Double = 0.0
    @Published var ratingDistribution: [Int] = [0, 0, 0, 0, 0]
    @Published var lastReview: Review?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var productImages: [ProductImage] = []
    @Published var imagesByProductId: [String: [String]] = [:]

    private struct SubmitReviewBody: Encodable {
        let rating: Int
        let text: String
    }

    enum ReviewAPIError: LocalizedError {
        case badStatus(Int)
        case notAuthorized
        case orderNotCompleted
        case unknown

        var errorDescription: String? {
            switch self {
            case .badStatus:
                return "reviewServerError"
            case .notAuthorized:
                return "authRequired"
            case .orderNotCompleted:
                return "Заказ не завершен"
            case .unknown:
                return "unknownError"
            }
        }
    }

    private func fetchImageURLs(for productId: String) async -> [String] {
        guard let url = URL(string: "\(baseURL)/product-images/images/by-product/\(productId)") else { return [] }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else { return [] }

            let decoded = try JSONDecoder().decode([ProductImage].self, from: data)

            let sorted = decoded.sorted {
                if $0.is_main != $1.is_main { return $0.is_main && !$1.is_main }
                return $0.sort_order < $1.sort_order
            }

            return sorted.map { $0.url }
        } catch {
            return []
        }
    }

    func prefetchImagesForLoadedProducts() async {
        let ids = products.map { $0.id }
        if ids.isEmpty { return }

        var dict = imagesByProductId

        await withTaskGroup(of: (String, [String]).self) { group in
            for id in ids {
                if dict[id] != nil { continue }
                group.addTask {
                    let urls = await self.fetchImageURLs(for: id)
                    return (id, urls)
                }
            }

            for await (id, urls) in group {
                dict[id] = urls
            }
        }

        imagesByProductId = dict
    }

    func loadImages(for productId: String) async {
        guard let url = URL(string: "\(baseURL)/product-images/images/by-product/\(productId)") else {
            productImages = []
            return
        }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else {
                productImages = []
                return
            }

            let decoded = try JSONDecoder().decode([ProductImage].self, from: data)

            let sorted = decoded.sorted {
                if $0.is_main != $1.is_main { return $0.is_main && !$1.is_main }
                return $0.sort_order < $1.sort_order
            }

            productImages = sorted
        } catch {
            productImages = []
        }
    }

    func loadProduct(by id: String) async {
        guard let url = URL(string: "\(baseURL)/products/products/\(id)") else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else {
                errorMessage = "productLoadError"
                selectedProduct = nil
                specs = []
                reviews = []
                productImages = []
                return
            }

            let product = try JSONDecoder().decode(Product.self, from: data)
            selectedProduct = product

            await loadImages(for: id)
            await loadSpecs(for: id)
            await loadReviews(for: id)

            if reviews.isEmpty {
                averageRating = Double(product.rating) ?? 0.0
                ratingDistribution = [0, 0, 0, 0, 0]
                lastReview = nil
            }
        } catch {
            errorMessage = "productLoadFailed"
            selectedProduct = nil
            specs = []
            reviews = []
            productImages = []
        }
    }

    func loadMyReview(productId: String, accessToken: String) async throws -> Review? {
        guard !accessToken.isEmpty else { throw ReviewAPIError.notAuthorized }
        guard let url = URL(string: "\(baseURL)/reviews/products/\(productId)/reviews/me") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: request)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0

        if code == 404 || code == 204 { return nil }
        guard (200...299).contains(code) else { throw ReviewAPIError.badStatus(code) }

        return try JSONDecoder().decode(Review.self, from: data)
    }

    @discardableResult
    func submitReview(productId: String, rating: Int, text: String, accessToken: String) async throws -> Review {
        guard !accessToken.isEmpty else { throw ReviewAPIError.notAuthorized }
        guard let url = URL(string: "\(baseURL)/reviews/products/\(productId)/reviews") else { throw ReviewAPIError.unknown }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(SubmitReviewBody(rating: rating, text: text))

        let (data, resp) = try await URLSession.shared.data(for: request)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0

        guard (200...299).contains(code) else {
            if code == 500 { throw ReviewAPIError.orderNotCompleted }
            throw ReviewAPIError.badStatus(code)
        }

        return try JSONDecoder().decode(Review.self, from: data)
    }

    func deleteMyReview(productId: String, accessToken: String) async throws {
        guard !accessToken.isEmpty else { throw ReviewAPIError.notAuthorized }
        guard let url = URL(string: "\(baseURL)/reviews/products/\(productId)/reviews/me") else { throw ReviewAPIError.unknown }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (_, resp) = try await URLSession.shared.data(for: request)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard (200...299).contains(code) else { throw ReviewAPIError.badStatus(code) }
    }

    func loadMyReviewByUserId(productId: String, myUserId: String) async -> Review? {
        guard let url = URL(string: "\(baseURL)/reviews/products/\(productId)/reviews") else { return nil }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else { return nil }
            let all = try JSONDecoder().decode([Review].self, from: data)
            return all.first(where: { $0.userId == myUserId })
        } catch {
            return nil
        }
    }

    func loadProductsByCategory(categoryId: String) async {
        guard let url = URL(string: "\(baseURL)/products/products/by-category/\(categoryId)") else { return }
        await fetchArray(url: url, into: \.products)
        await prefetchImagesForLoadedProducts()
    }

    func buildFiltersForCategoryProducts(_ products: [Product]) async -> [String: [String]] {
        var dict: [String: Set<String>] = [:]

        for p in products {
            guard let url = URL(string: "\(baseURL)/specs/specs/by-product/\(p.id)") else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let specs = try JSONDecoder().decode([ProductSpec].self, from: data)
                for s in specs {
                    dict[s.spec_name, default: []].insert(s.value)
                }
            } catch { }
        }

        var result: [String: [String]] = [:]
        for (k, v) in dict {
            result[k] = Array(v).sorted()
        }
        return result
    }

    func loadProducts() async {
        guard let url = URL(string: "\(baseURL)/products/products?limit=50&offset=0") else { return }
        await fetchArray(url: url, into: \.products)
        await prefetchImagesForLoadedProducts()
    }

    func loadProducts(by tag: String) async {
        guard let encoded = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/products/products/by-tags?tags=\(encoded)") else { return }
        await fetchArray(url: url, into: \.products)
        await prefetchImagesForLoadedProducts()
    }

    func loadTags() async {
        guard let url = URL(string: "\(baseURL)/tags/tags") else { return }
        await fetchArray(url: url, into: \.tags)
    }

    func loadSpecs(for productId: String) async {
        guard let url = URL(string: "\(baseURL)/specs/specs/by-product/\(productId)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            specs = try JSONDecoder().decode([ProductSpec].self, from: data)
        } catch {
            specs = []
        }
    }

    func loadReviews(for productId: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/products/\(productId)/reviews") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let loaded = try JSONDecoder().decode([Review].self, from: data)
            reviews = loaded
            calculateRatingStats(from: loaded)
        } catch {
            reviews = []
            averageRating = Double(selectedProduct?.rating ?? "0") ?? 0.0
            ratingDistribution = [0, 0, 0, 0, 0]
            lastReview = nil
        }
    }

    private func calculateRatingStats(from reviews: [Review]) {
        guard !reviews.isEmpty else {
            averageRating = Double(selectedProduct?.rating ?? "0") ?? 0.0
            ratingDistribution = [0, 0, 0, 0, 0]
            lastReview = nil
            return
        }

        var total = 0
        var counts = [0, 0, 0, 0, 0]

        for r in reviews {
            let rating = r.rating ?? 0
            guard (1...5).contains(rating) else { continue }
            total += rating
            counts[5 - rating] += 1
        }

        averageRating = Double(total) / Double(reviews.count)
        ratingDistribution = counts
        lastReview = reviews.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }.first
    }

    func loadProductsByIds(_ ids: [String]) async -> [Product] {
        var result: [Product] = []
        result.reserveCapacity(ids.count)

        for id in ids {
            guard let url = URL(string: "\(baseURL)/products/products/\(id)") else { continue }
            do {
                let (data, resp) = try await URLSession.shared.data(from: url)
                let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
                guard (200...299).contains(code) else { continue }
                let product = try JSONDecoder().decode(Product.self, from: data)
                result.append(product)
            } catch { }
        }

        return result
    }

    func fetchProduct(by id: String) async -> Product? {
        guard let url = URL(string: "\(baseURL)/products/products/\(id)") else { return nil }
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else { return nil }
            return try JSONDecoder().decode(Product.self, from: data)
        } catch {
            return nil
        }
    }

    func loadProductsBySpec(specName: String, value: String) async {
        guard
            let specEncoded = specName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let valueEncoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "\(baseURL)/products/products/by-spec?spec_name=\(specEncoded)&value=\(valueEncoded)")
        else { return }

        await fetchArray(url: url, into: \.products)
        await prefetchImagesForLoadedProducts()
    }

    private func fetchArray<T: Decodable>(
        url: URL,
        into keyPath: ReferenceWritableKeyPath<ProductManager, [T]>
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code) else {
                errorMessage = "serverError"
                self[keyPath: keyPath] = []
                return
            }

            self[keyPath: keyPath] = try JSONDecoder().decode([T].self, from: data)
        } catch {
            errorMessage = "networkError"
            self[keyPath: keyPath] = []
        }
    }
}
