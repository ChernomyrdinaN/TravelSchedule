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
        NavigationStack {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                // MARK: - Content
                ScrollView {
                    VStack(alignment: .leading, spacing: .zero) {
                        
                        // MARK: - Header
                        VStack(alignment: .leading, spacing: .zero) {
                            Text("Оферта на оказание образовательных услуг дополнительного\nобразования Яндекс.Практикум\nдля физических лиц")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.ypBlack)
                            
                            VStack(alignment: .leading, spacing: .zero) {
                                Text("Данный документ является действующим, если расположен по адресу: https://yandex.ru/legal/practicum_offer")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.ypBlack)
                                    .padding(.top, 8)
                                
                                Text("Российская Федерация, город Москва")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.ypBlack)
                                    .padding(.top, 16)
                            }
                        }
                        
                        // MARK: - Terms Section
                        VStack(alignment: .leading, spacing: .zero) {
                            Text("1. ТЕРМИНЫ")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.ypBlack)
                                .padding(.top, 24)
                            
                            VStack(alignment: .leading, spacing: .zero) {
                                Text("Понятия, используемые в Оферте, означают следующее:")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.ypBlack)
                                    .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: .zero) {
                                    Text("Авторизованные адреса — адреса электронной почты каждой Стороны. Авторизованным адресом Исполнителя является адрес электронной почты, указанный в разделе 11 Оферты. Авторизованным адресом Студента является адрес электронной почты, указанный Студентом в Личном кабинете.")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.ypBlack)
                                        .padding(.top, 24)
                                    
                                    Text("Вводный курс — начальный Курс обучения по представленным на Сервисе Программам обучения в рамках выбранной Студентом Профессии или Курсу, рассчитанный на определенное количество часов самостоятельного обучения, который предоставляется Студенту единожды при регистрации на Сервисе на безвозмездной основе. В процессе обучения в рамках Вводного курса Студенту предоставляется возможность ознакомления с работой Сервиса и определения возможности Студента продолжить обучение в рамках Полного курса по выбранной Студентом Программе обучения. Точное количество часов обучения в рамках Вводного курса зависит от выбранной Студентом Профессии или Курса и определяется в Программе обучения, размещенной на Сервисе. Максимальный срок освоения Вводного курса составляет 1 (один) год с даты начала обучения.")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.ypBlack)
                                        .padding(.top, 24)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
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
}

// MARK: - Preview
#Preview {
    UserAgreementView()
}
