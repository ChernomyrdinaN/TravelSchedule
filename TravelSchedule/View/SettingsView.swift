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
    
    // MARK: - Body
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
                            }
                            .frame(height: 60)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.ypWhite)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // MARK: - Info Section
                    VStack(spacing: 16) {
                        Text("Приложение использует API «Яндекс.Расписания»")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .multilineTextAlignment(.center)
                        
                        Text("Версия 1.0 (beta)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 44)
                    .padding(.bottom, 24)
                }
            }
            
           
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
