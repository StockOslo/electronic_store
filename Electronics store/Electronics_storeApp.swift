//
//  Electronics_storeApp.swift
//  Electronics store
//
//  Created by Erik Antonov on 28.10.2025.
//
import SwiftUI


@main
struct Electronics_storeApp: App {

    @StateObject private var userManager: UserManager
    @StateObject private var favoritesManager: FavoritesManager
    @StateObject private var cartManager: CartManager
    @StateObject private var ordersManager: OrdersManager
    @StateObject private var authManager = AuthManager()

    init() {
        let um = UserManager()
        _userManager = StateObject(wrappedValue: um)
        _favoritesManager = StateObject(wrappedValue: FavoritesManager())
        _cartManager = StateObject(wrappedValue: CartManager(userManager: um))
        _ordersManager = StateObject(wrappedValue: OrdersManager(userManager: um))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ProductsFeedScreen()
                    .tabItem { Image(systemName: "house"); Text("") }

                CategoriesScreen()
                    .tabItem { Image(systemName: "tag"); Text("") }

                FavoritesScreen()
                    .tabItem { Image(systemName: "heart"); Text("") }

                ShoppingBagScreen()
                    .tabItem { Image(systemName: "cart"); Text("") }

                RootView()
                    .tabItem { Image(systemName: "person"); Text("") }
            }
            .preferredColorScheme(.light)
            .environmentObject(userManager)
            .environmentObject(favoritesManager)
            .environmentObject(cartManager)
            .environmentObject(ordersManager)
            .environmentObject(authManager)
        }
    }
}
