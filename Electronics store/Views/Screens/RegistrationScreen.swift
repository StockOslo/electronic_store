//
//  RegistrationScreem.swift
//  Electronics store
//
//  Created by Erik Antonov on 31.10.2025.
//

import SwiftUI

struct RegistrationScreen: View {
    @State var name :String = "username"
    @State var email:String = "email"
    @State var password1 :String = "pswd"
    @State var password2:String = "pswd"
    var body: some View {
        VStack(spacing:20){
            Image(systemName: "person.badge.plus")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("registrationLabel")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing:20){
                Text("usrenameLabel")
                TextField("", text: $name).padding(14)
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
                Text("emailLabel")
                TextField("", text: $email).padding(14)
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
                Text("pswd1Label")
                SecureField("", text: $password1).padding(14)
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
                Text("pswd2Label")
                SecureField("", text: $password2).padding(14)
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
            Button(action: {
                    }) {
                        Text("registerBtnLabel")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 0)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green)
                                    .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    } 
                    .buttonStyle(.plain)
            
        }
        .padding(20)
                    .font(.system(size: 20))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

    }
}

#Preview {
    RegistrationScreen()
}
