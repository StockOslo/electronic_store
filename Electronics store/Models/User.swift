//
//  User.swift
//  Electronics store
//
//  Created by Erik Antonov on 03.01.2026.
//

import Foundation

// Ответ от GET /users/users/me
struct UserRequest: Decodable {
    let id: String
    let email: String
    let login: String
}

// POST /me/change-password
struct UserChangePasswordRequest: Encodable {
    let current_password: String
    let new_password: String
}

// POST /me/change-login
struct UserChangeLoginRequest: Encodable {
    let new_login: String
}
