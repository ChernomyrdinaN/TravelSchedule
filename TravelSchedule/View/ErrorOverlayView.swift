//
//  ErrorOverlayView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 14.10.2025.
//

import SwiftUI

struct ErrorOverlayView: View {
    let model: ErrorModel
    
    // MARK: - Body
    var body: some View {
        Color.clear
            .safeAreaInset(edge: .top) {
                ErrorView(errorModel: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(Color.clear)
                    .allowsHitTesting(false)
            }
    }
}
