//
//  LoginView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Logotipo
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
                
                // Título e Subtítulo
                VStack(spacing: 4) {
                    Text("FIRE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sistema de Detecção de Incêndio")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Campos de Entrada
                VStack(spacing: 12) {
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    SecureField("Senha", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Botão de Ação / Carregamento
                if authVM.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        authVM.login(email: email, pass: password)
                    }) {
                        Text("Entrar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Rodapé para Cadastro
                NavigationLink(destination: RegisterView(), isActive: $showRegister) {
                    Button("Não tem uma conta? Cadastre-se") {
                        showRegister = true
                    }
                    .font(.footnote)
                    .foregroundColor(.red)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Tela de Cadastro
struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Criar Conta")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Nome Completo", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                TextField("Telefone", text: $phone)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Senha", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                authVM.register(name: name, email: email, phone: phone, pass: password)
            }) {
                Text("Cadastrar e Conectar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}
