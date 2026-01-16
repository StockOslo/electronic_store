import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {

    @AppStorage("access_token") var accessToken: String?

    @Published var registrationSuccess = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "http://172.20.10.2:8000"

    func login(login: String, password: String) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            errorMessage = "invalidUrl"
            return
        }

        let body = LoginRequest(login: login, password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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

                guard let data = data,
                      let http = response as? HTTPURLResponse else {
                    self.errorMessage = "badServerResponse"
                    return
                }

                if http.statusCode == 200 {
                    do {
                        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                        self.accessToken = decoded.access_token
                    } catch {
                        self.errorMessage = "decodeError"
                    }
                } else {
                    let apiError = try? JSONDecoder().decode(APIError.self, from: data)
                    self.errorMessage = apiError?.detail ?? "loginError"
                }
            }
        }.resume()
    }

    func registration(email: String, login: String, password: String) {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            errorMessage = "invalidUrl"
            return
        }

        let body = RegisterRequest(email: email, login: login, password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = "encodeError"
            return
        }

        isLoading = true
        errorMessage = nil
        registrationSuccess = false

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data,
                      let http = response as? HTTPURLResponse else {
                    self.errorMessage = "badServerResponse"
                    return
                }

                if (200...299).contains(http.statusCode) {
                    do {
                        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                        self.accessToken = decoded.access_token
                        self.registrationSuccess = true
                    } catch {
                        self.errorMessage = "decodeError"
                    }
                } else {
                    let apiError = try? JSONDecoder().decode(APIError.self, from: data)
                    self.errorMessage = apiError?.detail ?? "registerError"
                }
            }
        }.resume()
    }

    func logout() {
        accessToken = nil
        registrationSuccess = false
        errorMessage = nil
        isLoading = false
    }
}
