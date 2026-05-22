//
//  DeviceDetailView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct DeviceDetailView: View {
    let device: Device
    @EnvironmentObject var iotVM: IoTViewModel
    @State private var isTesting = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Status Circular Visual
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 15)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(device.smokeLevel / 100.0, 1.0)))
                    .stroke(device.smokeLevel > 15 ? Color.red : Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Image(systemName: "smoke.fill")
                        .font(.largeTitle)
                        .foregroundColor(device.smokeLevel > 15 ? .red : .gray)
                    Text("\(String(format: "%.2f", device.smokeLevel))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Nível de Fumaça")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            // Grid de Métricas do Sistema
            VStack(spacing: 16) {
                HStack {
                    MetricTile(title: "Temperatura", value: "\(String(format: "%.2f", device.temperature))°C", icon: "thermometer")
                    MetricTile(title: "Bateria", value: "\(device.batteryLevel)%", icon: "bolt.fill")
                }
                HStack {
                    MetricTile(title: "Conexão", value: device.connectionType.rawValue, icon: "wifi")
                    MetricTile(title: "Estado", value: device.status.rawValue, icon: "checkmark.shield.fill")
                }
            }
            .padding(.horizontal)
            
            Spacer()
                .navigationBarTitle(device.name, displayMode: .inline)
        }
    }
    
    struct MetricTile: View {
        let title: String
        let value: String
        let icon: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .font(.title3)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}
