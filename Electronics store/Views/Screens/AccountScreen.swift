import SwiftUI

struct AccountScreen: View {

    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var ordersManager: OrdersManager

    @State private var showChangeLogin = false
    @State private var showChangePassword = false

    @State private var newLogin: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""

    private let buttonHeight: CGFloat = 52

    private func shortOrderNumber(_ id: String) -> String {
        String(id.prefix(6)).uppercased()
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    Text("accountTitle")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 92, height: 92)
                            .foregroundColor(.gray.opacity(0.65))

                        Text(userManager.login.isEmpty ? LocalizedStringKey("accountLoginPlaceholder") : LocalizedStringKey(userManager.login))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text(userManager.email.isEmpty ? LocalizedStringKey("accountEmailPlaceholder") : LocalizedStringKey(userManager.email))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    )

                    HStack(spacing: 32) {
                        Button {
                            showChangeLogin = true
                        } label: {
                            Text("changeLoginButton")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }

                        Button {
                            showChangePassword = true
                        } label: {
                            Text("changePasswordButton")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("lastPurchaseTitle")
                            .font(.headline)
                            .foregroundColor(.gray)

                        if ordersManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)

                        } else if let item = ordersManager.lastPurchasedItem,
                                  let order = ordersManager.lastOrder {

                            let title = item.product?.name ?? ""
                            let orderNumber = shortOrderNumber(order.id)
                            let date = todayString()
                            let priceText = "\(item.priceAtPurchase) ₽"

                            PurchaseCard(
                                title: title,
                                orderNumber: orderNumber,
                                date: date,
                                priceText: priceText,
                                iconName: "shippingbox",
                                productId: item.productId
                            )

                        } else {
                            Text("noPurchasesLabel")
                                .foregroundColor(.gray)
                                .italic()
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    )

                    NavigationLink {
                        AllPurchasesScreen()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue.opacity(0.12))
                                .frame(height: buttonHeight)

                            Text("allPurchasesButton")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)

                    PrimaryButton(titleKey: "logoutButton", height: buttonHeight, background: .red) {
                        userManager.accessToken = nil
                        userManager.clearProfile()
                        ordersManager.orders = []
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Color.white)
            .scrollIndicators(.hidden)
            .task {
                userManager.getMe()
                await ordersManager.loadMyOrders()
            }
            .onChange(of: userManager.accessToken) { _ in
                userManager.getMe()
                Task { await ordersManager.loadMyOrders() }
            }
            .sheet(isPresented: $showChangeLogin, onDismiss: { newLogin = "" }) {
                ChangeLoginSheet(
                    titleKey: "changeLoginTitle",
                    fieldPlaceholderKey: "newLoginPlaceholder",
                    buttonSaveKey: "saveButton",
                    buttonCancelKey: "cancelButton",
                    text: $newLogin,
                    onSave: {
                        userManager.changeLogin(newLogin: newLogin)
                        newLogin = ""
                        showChangeLogin = false
                    },
                    onCancel: {
                        newLogin = ""
                        showChangeLogin = false
                    }
                )
            }
            .sheet(isPresented: $showChangePassword, onDismiss: {
                currentPassword = ""
                newPassword = ""
            }) {
                ChangePasswordSheet(
                    titleKey: "changePasswordTitle",
                    currentPlaceholderKey: "currentPasswordPlaceholder",
                    newPlaceholderKey: "newPasswordPlaceholder",
                    buttonSaveKey: "updatePasswordButton",
                    buttonCancelKey: "cancelButton",
                    currentPassword: $currentPassword,
                    newPassword: $newPassword,
                    onSave: {
                        userManager.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                        currentPassword = ""
                        newPassword = ""
                        showChangePassword = false
                    },
                    onCancel: {
                        currentPassword = ""
                        newPassword = ""
                        showChangePassword = false
                    }
                )
            }
        }
    }
}

private struct PrimaryButton: View {
    let titleKey: LocalizedStringKey
    let height: CGFloat
    var background: Color = .green
    var foreground: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(background)
                    .frame(height: height)
                    .shadow(color: background.opacity(0.25), radius: 8, x: 0, y: 4)

                Text(titleKey)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(foreground)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ChangeLoginSheet: View {
    let titleKey: LocalizedStringKey
    let fieldPlaceholderKey: LocalizedStringKey
    let buttonSaveKey: LocalizedStringKey
    let buttonCancelKey: LocalizedStringKey

    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(titleKey)
                .font(.title2.bold())

            TextField(fieldPlaceholderKey, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            VStack(spacing: 10) {
                PrimaryButton(titleKey: buttonSaveKey, height: 52, background: .blue) {
                    onSave()
                }
                PrimaryButton(titleKey: buttonCancelKey, height: 52, background: Color(.systemGray5), foreground: .red) {
                    onCancel()
                }
            }
        }
        .padding(20)
        .presentationDetents([.medium])
    }
}

private struct ChangePasswordSheet: View {
    let titleKey: LocalizedStringKey
    let currentPlaceholderKey: LocalizedStringKey
    let newPlaceholderKey: LocalizedStringKey
    let buttonSaveKey: LocalizedStringKey
    let buttonCancelKey: LocalizedStringKey

    @Binding var currentPassword: String
    @Binding var newPassword: String

    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(titleKey)
                .font(.title2.bold())
            SecureField(newPlaceholderKey, text: $newPassword)
                .padding(14)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            VStack(spacing: 10) {
                PrimaryButton(titleKey: buttonSaveKey, height: 52, background: .green) {
                    onSave()
                }
                PrimaryButton(titleKey: buttonCancelKey, height: 52, background: Color(.systemGray5), foreground: .red) {
                    onCancel()
                }
            }
        }
        .padding(20)
        .presentationDetents([.medium])
    }
}
