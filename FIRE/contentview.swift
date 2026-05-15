//
//  ContentView.swift
//  FIRE
//
//  Created by joaoatilamonteiro on 15/05/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var iotVM: IoTViewModel
    
    var body: some View {
        Group {
            if authVM.isAuthenticated {
                if authVM.currentUser?.role == .admin {
                    AdminDashboardView()
                } else {
                    HomeDashboardView()
                }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authVM.isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthViewModel()
        let iot = IoTViewModel()
        
        ContentView()
            .environmentObject(auth)
            .environmentObject(iot)
    }
}
