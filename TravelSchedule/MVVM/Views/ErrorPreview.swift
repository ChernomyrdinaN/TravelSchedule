//
//  ErrorPreview.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

import SwiftUI

struct ErrorPreview: View {
    @State private var selectedError: ErrorModel.ErrorType = .noInternet
    
    var body: some View {
        VStack {
            Picker("Тип ошибки", selection: $selectedError) {
                Text("Нет интернета").tag(ErrorModel.ErrorType.noInternet)
                Text("Ошибка сервера").tag(ErrorModel.ErrorType.serverError)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            if selectedError == .noInternet {
                ErrorView(errorModel: .error1)
            } else {
                ErrorView(errorModel: .error2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ErrorPreview()
}
