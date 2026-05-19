//
//  AuthViewModel.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import Foundation
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    
    // 1. MUDANÇA PRINCIPAL: Já nasce como true (logado)
    @Published var isAuthenticated: Bool = true
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 2. ADICIONAMOS O INIT: Preenche os dados do usuário assim que o app abre
    init() {
        self.currentUser = User(id: "usr_123", name: "Usuário", email: "morador@fire.com", phone: "85988888888", role: .resident, familyMembers: ["fam_456"])
    }
    
    // As funções abaixo continuam existindo caso vocês precisem do botão de "Sair" depois,
    // mas elas não vão mais travar a entrada do app.
    func login(email: String, pass: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            if email.contains("admin") {
                self.currentUser = User(id: "usr_admin", name: "Carlos (Síndico)", email: email, phone: "85999999999", role: .admin, familyMembers: [])
            } else {
                self.currentUser = User(id: "usr_123", name: "Hélder Filipe", email: email, phone: "85988888888", role: .resident, familyMembers: ["fam_456"])
            }
            self.isAuthenticated = true
        }
    }
    
    func register(name: String, email: String, phone: String, pass: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.currentUser = User(id: UUID().uuidString, name: name, email: email, phone: phone, role: .resident, familyMembers: [])
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
