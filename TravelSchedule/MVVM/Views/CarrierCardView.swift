//
//  CarrierCardView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct CarrierCardView: View {
    let carrier: Carrier
    let onTimeClarificationTapped: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
    
            HStack(alignment: .top) {
                Image(carrier.logo)
                    .resizable()
                    .frame(width: 38, height: 38)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(carrier.name)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    
                    if let transferInfo = carrier.transferInfo {
                        Text(transferInfo)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.ypRed)
                    }
                }
                
                Spacer()
                
                Text(carrier.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypBlack)
            }
            

            if carrier.departureTime == "Уточнить время" {
                Button(action: onTimeClarificationTapped) {
                    Text("Уточнить время")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                HStack(spacing: 0) {
                    Text(carrier.departureTime)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                        .frame(width: 60, alignment: .leading)
                    
                    timelineView
                    
                    Text(carrier.arrivalTime)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color.ypWhite)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.ypLightGray, lineWidth: 1)
        )
    }
    
    private var timelineView: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.ypBlack)
                .frame(width: 8, height: 8)
            
            Rectangle()
                .fill(Color.ypLightGray)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text(carrier.travelTime)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.ypBlack)
                .fixedSize()
            
            Rectangle()
                .fill(Color.ypLightGray)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Circle()
                .fill(Color.ypBlack)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    VStack {
        CarrierCardView(
            carrier: Carrier(
                name: "РЖД",
                logo: "BrandIcon1",
                transferInfo: "С пересадкой в Костроме",
                date: "14 января",
                departureTime: "22:30",
                travelTime: "20 часов",
                arrivalTime: "08:15"
            ),
            onTimeClarificationTapped: {}
        )
        
        CarrierCardView(
            carrier: Carrier(
                name: "РЖД",
                logo: "BrandIcon1",
                transferInfo: nil,
                date: "17 января",
                departureTime: "Уточнить время",
                travelTime: "",
                arrivalTime: ""
            ),
            onTimeClarificationTapped: {}
        )
    }
    .padding()
}
