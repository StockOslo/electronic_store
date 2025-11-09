//
//  Electronics_storeApp.swift
//  Electronics store
//
//  Created by Erik Antonov on 28.10.2025.
//

import SwiftUI

@main
struct Electronics_storeApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ProductsFeedScreen()
                    .tabItem {
                        Image(systemName: "house")
                        Text("")
                    }
                

                CategoriesScreen()
                    .tabItem {
                        Image(systemName: "tag")
                        Text("")
                    }

                FavoritesScreen()
                    .tabItem {
                        Image(systemName: "heart")
                        Text("")
                    }

                ShoppingBagScreen()
                    .tabItem {
                        Image(systemName: "cart")
                        Text("")
                    }

               AccountScreen()
                    .tabItem {
                        Image(systemName: "person")
                        Text("")
                    }
            }
            .preferredColorScheme(.light)
        }
        
    }
}
