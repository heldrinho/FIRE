//
//  EmergencyContactsView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct EmergencyContactsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Cabeçalho com título e botão de fechar
            HStack {
                Text("Contatos de Emergência")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.bottom, 10)
            
            // Lista de Cartões de Chamada
            VStack(spacing: 16) {
                EmergencyContactCard(
                    title: "Bombeiros",
                    number: "193",
                    leftIcon: "shield"
                )
                
                EmergencyContactCard(
                    title: "SAMU",
                    number: "192",
                    leftIcon: "phone"
                )
                
                EmergencyContactCard(
                    title: "Polícia",
                    number: "190",
                    leftIcon: "shield"
                )
            }
            
            Spacer()
            
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
}

// MARK: - Cartão de Contato Customizado
struct EmergencyContactCard: View {
    let title: String
    let number: String
    let leftIcon: String
    
    var body: some View {
        Button(action: {
            // Efetua a ligação real ao clicar no card
            if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                // Ícone da esquerda
                Image(systemName: leftIcon)
                    .font(.system(size: 22))
                    .foregroundColor(.red)
                    .frame(width: 30)
                
                // Textos
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(number)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Ícone de telefone na direita
                Image(systemName: "phone")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            // Fundo avermelhado super suave com borda sutil
            .background(Color.red.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Evita o comportamento padrão de botão do iOS sobrepondo cores
    }
}

// MARK: - Pré-visualização no Xcode
struct EmergencyContactsView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyContactsView()
            .previewLayout(.sizeThatFits)
    }
}
