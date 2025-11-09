//
//  OrderSummaryCard.swift
//  Electronics store
//
//  Created by Erik Antonov on 02.11.2025.
//
import SwiftUI

struct OrderSummaryCard: View {
    let paymentMethods = ["SberBank", "SBP", "T-Bank"]
    
    @State var promoCode: String = " "
    @State var address: String = " "
    
    @State private var selectedPayMethod = "T-Bank"
    
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
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method)
                                    .tag(method)
                                    .foregroundColor(.gray)
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
                
                Divider()
                    .padding(.vertical, 6)
                
                HStack {
                    Text("TotalpriceLabel")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("158 000 ₽")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                .padding(.horizontal, 4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    OrderSummaryCard()
}
