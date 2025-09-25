//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 07.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Image("icSchedule")
                        .renderingMode(.template)
                }
                .tag(0)

            NavigationStack {
                ZStack {
                    Color.ypWhite
                        .ignoresSafeArea()
                    
                    Text("Настройки скоро будут реализованы")
                }
            }
            .tabItem {
                Image("icSettings")
                    .renderingMode(.template)
            }
            .tag(1)
        }
        .tint(.ypBlack)
        .onAppear {
            configureTabBarToHideText()
        }
    }
    
    // MARK: - Private Methods
    private func configureTabBarToHideText() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        
        let offset = UIOffset(horizontal: 0, vertical: 50)
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = offset
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = offset
        appearance.stackedLayoutAppearance.selected.iconColor = .ypBlack
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
