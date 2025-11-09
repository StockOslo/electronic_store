//
//  LoginScreen.swift
//  Electronics store
//
//  Created by Erik Antonov on 31.10.2025.
//

import SwiftUI

struct LoginScreen: View {
    @State var name:String = " "
    @State var password :String = " "
    var body: some View {
        VStack(spacing:20){
            Image(systemName: "person.fill.checkmark")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("loginBtnLabel")
                .font(.largeTitle)
            VStack(alignment: .leading, spacing:20){
                Text("usernameLabel")

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
                
                Text("pswdLabel")
                
                SecureField("", text: $password).padding(14)
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
                Button(action: {
                }) {
                    Text("loginBtnLabel")
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
}

#Preview {
    LoginScreen()
}
