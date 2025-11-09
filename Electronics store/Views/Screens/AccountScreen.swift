//
//  SettingsScreen.swift
//  Electronics store
//
//  Created by Erik Antonov on 30.10.2025.
//
import SwiftUI



struct AccountScreen: View {
    @State var login = " "
    @State var email = " "
    @State var pswd = " "
    @State var newPswd = " "
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                
                // Заголовок
                HStack {
                    Text("accountLabel")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Аватар и информация
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray.opacity(0.6))
                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                    
                    // Имя с кнопкой редактирования
                    HStack(spacing: 8) {
                        Text("nameLabel")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button(action: {

                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    

                }
                .padding(.top, 10)
                
                HStack{
                    Text("changeavatar")
                    Text("changepassword")
                    }
                
                
                // Покупки
                VStack(alignment: .leading, spacing: 10) {
                    Text("myPurchaseLabel")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 14) {
                        PurchaseCard(
                            title: "MacBook Air M3",
                            orderNumber: "12345",
                            date: "02.11.2025",
                            iconName: "laptopcomputer"
                        )
                        
                        PurchaseCard(
                            title: "MacBook Air M3",
                            orderNumber: "12345",
                            date: "02.11.2025",
                            iconName: "laptopcomputer"
                        )

                    }
                    .padding(.horizontal,15)
                }
                
                // Кнопка выхода
                VStack(spacing: 12) {
                    Button(action:{
                    }){
                        Text("allPurchaseBtnLabel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.blue)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    Button(action: {
                    }) {
                        Text("logOutBtnLabel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red)
                                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
    }
}


#Preview {
    AccountScreen()
}
