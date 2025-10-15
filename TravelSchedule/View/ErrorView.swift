//
//  ErrorView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

import SwiftUI

struct ErrorView: View {
    let errorModel: ErrorModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(errorModel.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .cornerRadius(70)

            Text(errorModel.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite)
        .contentShape(Rectangle())
    }
}
