import Foundation
import SwiftUI
import Combine

@MainActor
final class UserManager: ObservableObject {

    @AppStorage("access_token") var accessToken: String?

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var email = ""
    @Published var login = ""
    @Published var userId: String = ""

    private let baseURL = "http://172.20.10.2:8000"

    func getMe() {
        guard let token = accessToken, !token.isEmpty else {
            clearProfile()
            return
        }

        guard let url = URL(string: "\(baseURL)/users/users/me") else {
            errorMessage = "invalidUrl"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.errorMessage = "badServerResponse"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "emptyResponse"
                    return
                }

                guard (200...299).contains(http.statusCode) else {
                    if http.statusCode == 401 || http.statusCode == 403 {
                        self.accessToken = nil
                        self.clearProfile()
                        self.errorMessage = "sessionExpired"
                    } else {
                        self.errorMessage = "serverError"
                    }
                    return
                }

                do {
                    let user = try JSONDecoder().decode(UserRequest.self, from: data)
                    self.userId = user.id
                    self.email = user.email
                    self.login = user.login
                } catch {
                    self.errorMessage = "decodeError"
                }
            }
        }.resume()
    }

    func changePassword(currentPassword: String, newPassword: String) {
        guard let url = URL(string: "\(baseURL)/users/users/me/change-password") else {
            errorMessage = "invalidUrl"
            return
        }

        guard let token = accessToken, !token.isEmpty else {
            errorMessage = "authRequired"
            return
        }

        let body = UserChangePasswordRequest(
            current_password: currentPassword,
            new_password: newPassword
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = "encodeError"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.errorMessage = "badServerResponse"
                    return
                }

                guard (200...299).contains(http.statusCode) else {
                    if http.statusCode == 401 || http.statusCode == 403 {
                        self.accessToken = nil
                        self.clearProfile()
                        self.errorMessage = "sessionExpired"
                    } else {
                        self.errorMessage = "changePasswordError"
                    }
                    return
                }
            }
        }.resume()
    }

    func changeLogin(newLogin: String) {
        guard let url = URL(string: "\(baseURL)/users/users/me/change-login") else {
            errorMessage = "invalidUrl"
            return
        }

        guard let token = accessToken, !token.isEmpty else {
            errorMessage = "authRequired"
            return
        }

        let body = UserChangeLoginRequest(new_login: newLogin)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = "encodeError"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.errorMessage = "badServerResponse"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "emptyResponse"
                    return
                }

                guard (200...299).contains(http.statusCode) else {
                    if http.statusCode == 401 || http.statusCode == 403 {
                        self.accessToken = nil
                        self.clearProfile()
                        self.errorMessage = "sessionExpired"
                    } else {
                        self.errorMessage = "changeLoginError"
                    }
                    return
                }

                do {
                    let user = try JSONDecoder().decode(UserRequest.self, from: data)
                    self.login = user.login
                } catch {
                    self.errorMessage = "decodeError"
                }
            }
        }.resume()
    }

    func clearProfile() {
        email = ""
        login = ""
        userId = ""
        errorMessage = nil
        isLoading = false
    }
}
