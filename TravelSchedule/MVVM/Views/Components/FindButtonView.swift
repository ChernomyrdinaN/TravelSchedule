//
//  FindButtonView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

struct FindButtonView: View {
    let fromStation: Station?
    let toStation: Station?
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {}) {
            Text("Найти")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypWhite1)
                .frame(width: 150, height: 60)
                .background(Color.ypBlue)
                .cornerRadius(12)
        }
        .disabled(fromStation == nil || toStation == nil)
        .opacity((fromStation == nil || toStation == nil) ? 0.5 : 1.0)
    }
}

#Preview {
    FindButtonView(
        fromStation: Station(name: "Москва"),
        toStation: Station(name: "Санкт-Петербург")
    )
}
