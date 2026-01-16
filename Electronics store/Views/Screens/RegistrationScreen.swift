import SwiftUI

struct RegistrationScreen: View {

    @State private var username = ""
    @State private var email = ""
    @State private var password1 = ""
    @State private var password2 = ""
    @State private var localError: String?

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {

            HStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 32))
                    .foregroundStyle(.tint)

                Text("registerTitle")
                    .font(.largeTitle)
                    .bold()
            }

            VStack(alignment: .leading, spacing: 16) {

                Text("usernameLabel")
                TextField("usernamePlaceholder", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .modifier(CustomInputStyle())

                Text("emailLabel")
                TextField("emailPlaceholder", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .modifier(CustomInputStyle())

                Text("passwordLabel")
                SecureField("passwordPlaceholder", text: $password1)
                    .modifier(CustomInputStyle())

                Text("repeatPasswordLabel")
                SecureField("repeatPasswordPlaceholder", text: $password2)
                    .modifier(CustomInputStyle())

                if let error = localError {
                    Text(LocalizedStringKey(error))
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let error = authManager.errorMessage {
                    Text(LocalizedStringKey(error))
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    register()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                            .frame(height: 48)

                        if authManager.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("registerButton")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                }
                .disabled(authManager.isLoading)
            }
        }
        .padding()
        .background(Color.white)
        .onChange(of: authManager.accessToken) { _ in
            if authManager.accessToken != nil {
                dismiss()
            }
        }
    }

    private func register() {
        localError = nil
        authManager.errorMessage = nil

        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let p1 = password1
        let p2 = password2

        guard !u.isEmpty, !e.isEmpty, !p1.isEmpty, !p2.isEmpty else {
            localError = "fillAllFieldsError"
            return
        }

        guard isValidUsername(u) else {
            localError = "invalidUsernameError"
            return
        }

        guard isValidEmail(e) else {
            localError = "Почта не подходит"
            return
        }

        guard p1 == p2 else {
            localError = "Пароли не совподают"
            return
        }


        authManager.registration(email: e, login: u, password: p1)
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    private func isValidUsername(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (3...20).contains(trimmed.count) else { return false }
        let pattern = #"^[A-Za-z0-9_]+$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}
