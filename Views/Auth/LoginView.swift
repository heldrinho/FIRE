//
//  LoginView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//

import SwiftUI

// MARK: - Tela Única de Boas-Vindas e Acesso (RF02 - Autenticação Simplificada para Demo)
struct LoginView: View {
    // Obrigatório para performar a ação de login injetando dados fictícios
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        // Eliminamos o NavigationView pois não há mais navegação para outras telas aqui
        VStack(spacing: 30) {
            Spacer()
            
            // 1. Logo Grande Centralizado
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            
            // 2. Textos de Boas-vindas
            VStack(spacing: 12) {
                Text("Bem-vindo ao FIRE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("O seu sistema inteligente de detecção de incêndio. Proteção 24h para você e sua família.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // 3. Área de Ação Direta (RF02 - Autenticação Simplificada)
            // Lógica trazida da antiga SignInView para esta tela única
            if authVM.isLoading {
                // Estado de carregamento enquanto o AuthViewModel processa
                ProgressView()
                    .padding()
            } else {
                // Botão único de ação direta na tela principal
                // Injeta credenciais fictícias para pular o formulário (requisito do usuário)
                Button(action: {
                    // Injetamos credenciais demo para teste rápido do painel residencial
                    // Ex: morador@fire.com / pass: 123
                    authVM.login(email: "morador@fire.com", pass: "123")
                }) {
                    Text("Acessar Painel de Monitoramento")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// Eliminadas struct SignInView (lógica mesclada)
// Eliminadas struct RegisterView (acesso removido)
