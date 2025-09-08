//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 07.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - First Tab (Schedule)
            NavigationStack {
                ZStack {
                    Color.ypWhite
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Контент расписания будет здесь")
                            .padding()
                        Spacer()
                    }
                }
            }
            .tabItem {
                Image("icSchedule")
                    .renderingMode(.template)
            }
            .tag(0)
            
            // MARK: - Second Tab (Settings)
            NavigationStack {
                ZStack {
                    Color.ypWhite
                        .ignoresSafeArea()
                    
                    Text("Экран настроек будет здесь")
                }
            }
            .tabItem {
                Image("icSettings")
                    .renderingMode(.template) 
            }
            .tag(1)
        }
        .tint(.black)
        .onAppear {
            configureTabBarToHideText()
        }
    }
    
    // MARK: - TabBar Configuration
    private func configureTabBarToHideText() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let offset = UIOffset(horizontal: 0, vertical: 50)
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = offset
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = offset
        appearance.stackedLayoutAppearance.selected.iconColor = .black
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
