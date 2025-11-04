//
//  RegistrationScreem.swift
//  Electronics store
//
//  Created by Erik Antonov on 31.10.2025.
//

import SwiftUI

struct RegistrationScreen: View {
    @Binding var name :String
    @Binding var email:String
    @Binding var password1 :String
    @Binding var password2:String
    var body: some View {
        VStack(spacing:20){
            TextField("UserName", text: $name).padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                        )
                )
                .foregroundColor(.blue)
                .accentColor(.blue)
                .font(.system(size: 18, weight: .medium))
                .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
            TextField("Email", text: $email).padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                        )
                )
                .foregroundColor(.blue)
                .accentColor(.blue)
                .font(.system(size: 18, weight: .medium))
                .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
            SecureField("Password", text: $password1).padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                        )
                )
                .foregroundColor(.blue)
                .accentColor(.blue)
                .font(.system(size: 18, weight: .medium))
                .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
            SecureField("Password", text: $password2).padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                        )
                )
                .foregroundColor(.blue)
                .accentColor(.blue)
                .font(.system(size: 18, weight: .medium))
                .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(20)
                    .font(.system(size: 20))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

    }
}

#Preview {
    RegistrationScreen(name: .constant("Имя пользователя"),
                       email: .constant("example@mail.com"),
                       password1: .constant("123456"),
                       password2: .constant("123456")
    )
}
