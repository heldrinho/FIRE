//
//  AdminDashboardView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0
    
    // Dados mocados para o condomínio
    @State private var apartments = [
        ApartmentNode(id: "101", owner: "Usuário", status: .online, batteryWarning: false),
        ApartmentNode(id: "102", owner: "Roberto", status: .alert, batteryWarning: false), // Fogo simulado
        ApartmentNode(id: "201", owner: "Ana Beatriz", status: .offline, batteryWarning: true),
        ApartmentNode(id: "202", owner: "Vago", status: .offline, batteryWarning: false)
    ]
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // TAB 1: Painel Geral e Alertas
                VStack(spacing: 0) {
                    // Estatísticas de Monitoramento Centralizado
                    HStack {
                        AdminStatCard(title: "Ativos", value: "3", color: .green)
                        AdminStatCard(title: "Em Alerta", value: "1", color: .red)
                        AdminStatCard(title: "Offline", value: "1", color: .gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                    List {
                        Section(header: Text("Unidades em Alerta / Atenção")) {
                            ForEach(apartments.filter { $0.status != .online }) { apt in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Apt \(apt.id)")
                                            .font(.headline)
                                        Text("Responsável: \(apt.owner)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if apt.status == .alert {
                                        Text("FUMAÇA DETECTADA")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(6)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    } else if apt.status == .offline {
                                        Text("Sensor Desconectado")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Central")
                }
                .tag(0)
                
                // TAB 2: Mapa do Prédio (Matriz)
                VStack {
                    Text("Planta Virtual — Torre A")
                        .font(.headline)
                        .padding(.top)
                    
                    // Representação gráfica das unidades do prédio
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(apartments) { apt in
                            VStack {
                                Text(apt.id)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: apt.status == .alert ? "flame.fill" : "sensor.tag.radiowaves.forward")
                                    .font(.system(size: 28))
                                    .foregroundColor(colorForStatus(apt.status))
                                Text(apt.owner.components(separatedBy: " ").first ?? "")
                                    .font(.caption)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(colorForStatus(apt.status), lineWidth: apt.status == .alert ? 3 : 0))
                        }
                    }
                    .padding()
                    Spacer()
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Mapa")
                }
                .tag(1)
            }
            .navigationBarTitle("Painel do Síndico", displayMode: .inline)
            .navigationBarItems(trailing: Button("Sair") { authVM.logout() })
        }
    }
    
    private func colorForStatus(_ status: DeviceStatus) -> Color {
        switch status {
        case .online: return .green
        case .alert: return .red
        case .offline: return .gray
        }
    }
}

struct ApartmentNode: Identifiable {
    let id: String
    let owner: String
    let status: DeviceStatus
    let batteryWarning: Bool
}

struct AdminStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
