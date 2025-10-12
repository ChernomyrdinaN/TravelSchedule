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
    let onFindTapped: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onFindTapped) {
            Text("Найти")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.ypWhiteUniversal)
                .frame(width: 150, height: 60)
                .background(.ypBlueUniversal)
                .cornerRadius(12)
        }
        .disabled(fromStation == nil || toStation == nil)
        .opacity((fromStation == nil || toStation == nil) ? 0.5 : 1.0)
    }
}

