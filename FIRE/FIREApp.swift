//
//  FIREApp.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//

import SwiftUI

@main
struct FIREApp: App {
    @StateObject var authVM = AuthViewModel()
    @StateObject var iotVM = IoTViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                if authVM.currentUser?.role == .admin {
                    AdminDashboardView()
                        .environmentObject(authVM)
                        .environmentObject(iotVM)
                } else {
                    HomeDashboardView()
                        .environmentObject(authVM)
                        .environmentObject(iotVM)
                }
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}
