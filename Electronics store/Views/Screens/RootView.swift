import SwiftUI

struct RootView: View {
    @AppStorage("access_token") private var accessToken: String?

    @StateObject private var authManager = AuthManager()
    @StateObject private var userManager = UserManager()

    private var isAuthorized: Bool {
        guard let t = accessToken else { return false }
        return !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isAuthorized {
                    AccountScreen()
                } else {
                    LoginScreen()
                }
            }
        }
        .environmentObject(authManager)
        .environmentObject(userManager)

        .task {
            userManager.getMe()
        }
        .onChange(of: accessToken) { _ in
            userManager.getMe()

            if !isAuthorized {
                userManager.clearProfile()
            }
        }
    }
}
