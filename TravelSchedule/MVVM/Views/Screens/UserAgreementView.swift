//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 26.09.2025.
//

import SwiftUI

struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
        
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Оферта на оказание образовательных услуг дополнительного образования Яндекс.Практикум для физических лиц")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.ypBlack)
                        
                        Text("Данный документ является действующим, если расположен по адресу: https://yandex.ru/legal/practicum_offer")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.ypBlack)
                        
                        Text("Российская Федерация, город Москва")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.ypBlack)
                        
                        Text("1. ТЕРМИНЫ")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.ypBlack)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Понятия, используемые в Оферте, означают следующее:")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            Text("Авторизованные адреса — адреса электронной почты каждой Стороны. Авторизованным адресом Исполнителя является адрес электронной почты, указанный в разделе 11 Оферты. Авторизованным адресом Студента является адрес электронной почты, указанный Студентом в Личном кабинете.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            Text("Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            Text("Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            
                            Text("Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                            
                            
                            Text("Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.ypBlack)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Пользовательское соглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.ypBlack)
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }


// MARK: - Preview
#Preview {
    UserAgreementView()
}
