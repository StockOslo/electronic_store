import SwiftUI

struct LoginScreen: View {

    @State private var name: String = ""
    @State private var password: String = ""

    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "person.fill.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Вход")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 16) {

                Text("loginFieldTitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("loginPlaceholder", text: $name)
                    .modifier(CustomInputStyle())

                Text("passwordFieldTitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                SecureField("passwordPlaceholder", text: $password)
                    .modifier(CustomInputStyle())

                if let error = authManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    authManager.login(login: name, password: password)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.green)
                            .frame(height: 52)

                        if authManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("loginButton")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(authManager.isLoading)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                NavigationLink("registrationButton", destination: RegistrationScreen())
                NavigationLink("forgotPasswordButton", destination: Text("resetPasswordPlaceholder"))
            }
            .font(.subheadline)
        }
        .padding(24)
        .background(Color.white)
    }
}

struct CustomInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.05))
                    )
            )
            .textInputAutocapitalization(.none)
            .autocorrectionDisabled()
    }
}

