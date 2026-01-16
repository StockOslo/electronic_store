import SwiftUI

struct OrderSummaryCard: View {
    let paymentMethods = ["SberBank", "SBP", "T-Bank"]

    @Binding var promoCode: String
    @Binding var address: String
    @Binding var selectedPayMethod: String

    var body: some View {
        HStack(spacing: 18) {
            VStack(spacing: 18) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("promoLabel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    TextField("", text: $promoCode)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                                .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .foregroundColor(.gray)
                        .accentColor(.gray)
                        .font(.system(size: 16, weight: .medium))
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("adressLabel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    TextField("", text: $address)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                                .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .foregroundColor(.gray)
                        .accentColor(.gray)
                        .font(.system(size: 16, weight: .medium))
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("paymentmethodLabel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    HStack {
                        Picker("", selection: $selectedPayMethod) {
                            Text("Выбрать").tag("")

                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.gray)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
            }
        }
    }
}
