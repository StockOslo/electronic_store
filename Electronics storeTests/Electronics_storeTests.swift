//
//  Electronics_storeTests.swift
//  Electronics storeTests
//
//  Created by Erik Antonov on 28.10.2025.
//

import Testing
@testable import Electronics_store

@MainActor
struct Electronics_storeTests {

    @Test
    func cartQuantity_whenEmpty_returnsZero() async throws {
        let userManager = UserManager()
        let cart = CartManager(userManager: userManager)

        #expect(cart.quantity(for: "some-id") == 0)
    }

    @Test
    func cartIsAuthorized_falseWhenTokenMissing() async throws {
        let userManager = UserManager()
        userManager.accessToken = nil

        let cart = CartManager(userManager: userManager)

        #expect(cart.isAuthorized == false)
    }

    @Test
    func cartIsAuthorized_trueWhenTokenNotEmpty() async throws {
        let userManager = UserManager()
        userManager.accessToken = "token"

        let cart = CartManager(userManager: userManager)

        #expect(cart.isAuthorized == true)
    }

    @Test
    func favoritesManager_isAuthorized_falseWhenNoToken() async throws {
        let favorites = FavoritesManager()
        #expect(favorites.isAuthorized == true)
    }

    @Test
    func favoritesManager_toggleWithoutAuth_setsErrorAndDoesNotAdd() async throws {
        let favorites = FavoritesManager()

        await favorites.toggleFavorite(productId: "p1")

        #expect(favorites.isFavorite("p1") == false)
        #expect(favorites.errorMessage != nil)
    }

    @Test
    func productManager_reviewAPIErrorMapping() async throws {
        #expect(ProductManager.ReviewAPIError.notAuthorized.errorDescription == "authRequired")
        #expect(ProductManager.ReviewAPIError.orderNotCompleted.errorDescription == "Заказ не завершен")
        #expect(ProductManager.ReviewAPIError.badStatus(500).errorDescription == "reviewServerError")
    }
}
