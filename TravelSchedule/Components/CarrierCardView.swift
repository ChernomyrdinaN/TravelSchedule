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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            timeSection
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.ypLightGray, lineWidth: 1)
        )
    }
}

// MARK: - Private Views
private extension CarrierCardView {
    var headerSection: some View {
        HStack(alignment: .top) {
            carrierLogoImage
                .frame(width: 38, height: 38)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(carrier.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlackUniversal)
                
                if let transferInfo = carrier.transferInfo {
                    Text(transferInfo)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypRed)
                }
            }
            
            Spacer()
            
            Text(carrier.date)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.ypBlackUniversal)
        }
    }
    
    var timeSection: some View {
        ZStack {
            clarificationButton
                .opacity(carrier.departureTime == "Уточнить время" ? 1 : 0)
            
            scheduleView
                .opacity(carrier.departureTime == "Уточнить время" ? 0 : 1)
        }
    }

    var clarificationButton: some View {
        Button(action: onTimeClarificationTapped) {
            Text("Уточнить время")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlueUniversal)
                .frame(maxWidth: .infinity)
        }
    }
    
    var scheduleView: some View {
        HStack(spacing: .zero) {
            Text(carrier.departureTime)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlackUniversal)
                .frame(width: 60, alignment: .leading)
            
            timelineView
            
            Text(carrier.arrivalTime)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlackUniversal)
                .frame(width: 60, alignment: .trailing)
        }
    }
    
    var timelineView: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(.ypGrayUniversal)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text(carrier.travelTime)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.ypBlackUniversal)
                .fixedSize()
            
            Rectangle()
                .fill(.ypGrayUniversal)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }
    
    var carrierLogoImage: some View {
        Group {
            if let url = validLogoURL(carrier.logo) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                    case .failure:
                        placeholderLogo
                    @unknown default:
                        placeholderLogo
                    }
                }
            } else {
                placeholderLogo
            }
        }
    }
    
    var placeholderLogo: some View {
        ZStack {
            Color.white
            Image(systemName: "train.side.front.car")
                .foregroundColor(.ypBlack)
        }
    }
}

// MARK: - Private Methods
private extension CarrierCardView {
    func validLogoURL(_ logoString: String) -> URL? {
        guard !logoString.isEmpty,
              let url = URL(string: logoString),
              let scheme = url.scheme,
              scheme.hasPrefix("http") else {
            return nil
        }
        return url
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CarrierCardView(
            carrier: Carrier(
                name: "РЖД",
                logo: "https://yastat.net/s3/rasp/media/data/company/logo/logo.gif",
                transferInfo: "С пересадкой в Костроме",
                date: "14 января",
                departureTime: "22:30",
                travelTime: "20 часов",
                arrivalTime: "08:15",
                code: "RZD"
            ),
            onTimeClarificationTapped: {}
        )
        
        CarrierCardView(
            carrier: Carrier(
                name: "Без логотипа",
                logo: "",
                transferInfo: nil,
                date: "17 января",
                departureTime: "Уточнить время",
                travelTime: "",
                arrivalTime: "",
                code: "RZD"
            ),
            onTimeClarificationTapped: {}
        )
    }
    .padding()
    .frame(width: 360)
}
