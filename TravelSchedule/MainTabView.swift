//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 07.09.2025.
//
//

import SwiftUI

// MARK: - Notification Names Extension
extension Notification.Name {
    static let resetMainNavigation = Notification.Name("resetMainNavigation")
    static let serverErrorOccurred = Notification.Name("serverErrorOccurred")
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("isDarkTheme") private var isDarkTheme = false

    @EnvironmentObject private var overlay: AppOverlayCenter
    @EnvironmentObject private var net: NetworkChecker
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MainView()
            }
            .tabItem {
                Image("icSchedule")
                    .renderingMode(.template)
            }
            .tag(0)
            
            SettingsView()
                .tabItem {
                    Image("icSettings")
                        .renderingMode(.template)
                }
                .tag(1)
        }
        .preferredColorScheme(isDarkTheme ? .dark : .light)
        .tint(.ypBlack)
        .onAppear {
            configureTabBarToHideText()
            overlay.isInternetDown = (net.state == .offline)
            if overlay.isInternetDown {
                selectedTab = 1
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue == newValue && newValue == 0 {
                NotificationCenter.default.post(name: .resetMainNavigation, object: nil)
            }
        }
        .onChange(of: net.state) { _, newValue in
            overlay.isInternetDown = (newValue == .offline)
            if overlay.isInternetDown {
                selectedTab = 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .serverErrorOccurred)) { _ in
            selectedTab = 1
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
