//
//  HomeDashboardView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var iotVM: IoTViewModel
    @State private var showAddDevice = false
    @State private var showHistory = false
    @State private var showEmergencyContacts = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Cabeçalho de Boas-vindas
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Olá, \(authVM.currentUser?.name ?? "Morador")")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Status da Residência: Monitorado")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Button(action: { authVM.logout() }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Alerta de Emergência em Destaque (RF10 / Notificações)
                    if let emergency = iotVM.activeEmergency {
                        EmergencyBannerView(event: emergency) {
                            iotVM.activeEmergency = nil
                        }
                        .padding(.horizontal)
                    }
                    
                    // Botão Rápido de Emergência (RF10)
                    EmergencyQuickButton(showContacts: $showEmergencyContacts)
                        .padding(.horizontal)
                        .sheet(isPresented: $showEmergencyContacts) {
                            EmergencyContactsView()
                        }
                    
                    // Listagem de Ambientes e Sensores (RF04, RF07)
                    Text("Seus Dispositivos")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(iotVM.devices) { device in
                            NavigationLink(destination: DeviceDetailView(device: device)) {
                                DeviceCardView(device: device)
                            }
                        }
                        
                        // Botão Adicionar Dispositivo
                        Button(action: { showAddDevice = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.red)
                                Text("Adicionar")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5])))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Atalho para Histórico e Compartilhamento Familiar
                    HStack(spacing: 16) {
                        Button(action: { showHistory = true }) {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("Histórico")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                        
                        NavigationLink(destination: FamilySharingView()) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Família")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                        .foregroundColor(.primary)
                    }
                    .padding()
                }
                .padding(.top)
            }
            .navigationBarTitle("FIRE", displayMode: .inline)
            .sheet(isPresented: $showAddDevice) {
                AddDeviceView()
                    .environmentObject(iotVM)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView()
                    .environmentObject(iotVM)
            }
        }
    }
}

// MARK: - Componentes de Apoio
struct EmergencyQuickButton: View {
    @Binding var showContacts: Bool
    
    var body: some View {
        Button(action: {
            // Ao clicar, muda o estado para exibir a modal
            showContacts = true
        }) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("ACIONAR EMERGÊNCIA")
                        .font(.headline)
                    Text("Toque para ver telefones e rotas")
                        .font(.caption)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
            .shadow(color: .red.opacity(0.4), radius: 5, x: 0, y: 3)
        }
    }
}


struct EmergencyBannerView: View {
    let event: AlertEvent
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                Text("ALERTA CRÍTICO DE INCÊNDIO")
                    .fontWeight(.bold)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            Text("Origem: \(event.deviceName)")
                .font(.subheadline)
            Text("Evacue o local imediatamente seguindo as rotas seguras.")
                .font(.footnote)
        }
        .padding()
        .background(Color.orange)
        .foregroundColor(.white)
        .cornerRadius(12)
        // Efeito de pulso para chamar atenção visual
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 3))
    }
}

struct DeviceCardView: View {
    let device: Device
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: device.status == .online ? "sensor.tag.radiowaves.forward" : "exclamationmark.circle.fill")
                    .foregroundColor(device.status == .online ? .green : .red)
                Spacer()
                // Nível de bateria visual
                HStack(spacing: 2) {
                    Image(systemName: device.batteryLevel < 20 ? "battery.25" : "battery.100")
                    Text("\(device.batteryLevel)%")
                        .font(.caption2)
                }
                .foregroundColor(device.batteryLevel < 20 ? .red : .gray)
            }
            
            Spacer()
            
            Text(device.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            HStack {
                Text("\(String(format: "%.1f", device.temperature))°C")
                Spacer()
                Text("\(String(format: "%.1f", device.smokeLevel))% Fumaça")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
