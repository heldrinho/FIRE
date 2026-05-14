//
//  FamilySharingView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct FamilySharingView: View {
    @State private var inviteEmail = ""
    @State private var familyMembers = ["Maria Clara (Esposa)", "João (Filho)"]
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Adicionar Membro")) {
                    HStack {
                        TextField("E-mail do familiar", text: $inviteEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Button("Convidar") {
                            if !inviteEmail.isEmpty {
                                familyMembers.append(inviteEmail)
                                inviteEmail = ""
                            }
                        }
                        .foregroundColor(.red)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Section(header: Text("Membros com Acesso")) {
                    ForEach(familyMembers, id: \.self) { member in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            Text(member)
                            Spacer()
                            Text("Ativo")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete { indexSet in
                        familyMembers.remove(atOffsets: indexSet)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Grupo Familiar", displayMode: .inline)
    }
}
