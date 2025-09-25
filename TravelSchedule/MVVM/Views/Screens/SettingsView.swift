//
//  SettingsView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 25.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkTheme") private var isDarkTheme = false
    @State private var showUserAgreement = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                VStack(spacing: .zero) {
                    
                    VStack(spacing: .zero) {
                        
                        HStack {
                            Text("Темная тема")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isDarkTheme)
                                .labelsHidden()
                                .tint(.ypBlueUniversal)
                                .frame(width: 51, height: 31)
                        }
                        
                        .frame(height: 60)
                        
                        
                        NavigationLink(destination: UserAgreementView()) {
                            HStack {
                                Text("Пользовательское соглашение")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.ypBlack)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.ypBlack)
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .frame(height: 60)
                        }
                        .buttonStyle(PlainButtonStyle()) 
                    }
                    .background(Color.ypWhite)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    
                    VStack(spacing: 30) {
                        Text("Приложение использует API «Яндекс.Расписания»")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .multilineTextAlignment(.center)
                        
                            .tracking(0.4) // letter-spacing: 0.4px
                        
                        Text("**Версия 1.0 (beta)**")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .multilineTextAlignment(.center)
                            .tracking(0.4) // letter-spacing: 0.4px
                    }
                    
                    .padding(.bottom, 24)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.ypBlack)
                    }
                }
            }
            .toolbar(.visible, for: .tabBar) 
            .preferredColorScheme(isDarkTheme ? .dark : .light)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
