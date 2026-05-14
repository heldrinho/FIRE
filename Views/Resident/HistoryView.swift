//
//  HistoryView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iotVM: IoTViewModel
    
    var body: some View {
        NavigationView {
            List(iotVM.history) { event in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: iconForType(event.type))
                        .foregroundColor(colorForType(event.type))
                        .font(.title2)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.type.rawValue)
                            .font(.headline)
                        Text("Sensor: \(event.deviceName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(formatDate(event.timestamp))
                            if event.durationSeconds > 0 {
                                Text("• Duração: \(event.durationSeconds)s")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationBarTitle("Histórico de Eventos", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func iconForType(_ type: AlertType) -> String {
        switch type {
        case .smoke, .fire: return "flame.fill"
        case .lowBattery: return "battery.25"
        case .disconnected: return "wifi.exclamationmark"
        case .test: return "speaker.wave.3.fill"
        }
    }
    
    private func colorForType(_ type: AlertType) -> Color {
        switch type {
        case .fire: return .red
        case .smoke: return .orange
        case .lowBattery, .disconnected: return .yellow
        case .test: return .blue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
