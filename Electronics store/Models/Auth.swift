//
//  Auth.swift
//  Electronics store
//
//  Created by Erik Antonov on 30.12.2025.
//

import Foundation


struct LoginRequest: Encodable {
    let login: String
    let password: String
}
struct RegisterRequest: Encodable {
    let email: String
    let login: String
    let password: String
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
}

// Модель для ошибок (если API вернет 400 или 401)
struct APIError: Decodable {
    let detail: String
}
