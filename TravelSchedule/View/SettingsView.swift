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

    @EnvironmentObject private var overlay: AppOverlayCenter
    
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

                if let apiError = overlay.serverErrorToShow {
                    ErrorOverlayView(model: ErrorModel.fromAPIError(apiError))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if overlay.isInternetDown {
                    ErrorOverlayView(model: .noInternet)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .serverErrorOccurred)) { note in
            if let code = note.userInfo?["code"] as? Int {
                overlay.showServerError(.serverError(code))
            } else {
                overlay.showServerError(.serverError(0))
            }
        }
        .onDisappear {
            overlay.clearServerError()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DIContainer.shared.overlayCenter)
}
