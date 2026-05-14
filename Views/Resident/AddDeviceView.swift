//
//  AddDeviceView.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import SwiftUI

struct AddDeviceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iotVM: IoTViewModel
    
    @State private var deviceName = ""
    @State private var selectedRoom: RoomType = .kitchen
    @State private var connectionType: ConnectionType = .wifi
    @State private var isScanningQR = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Identificação do Sensor")) {
                    TextField("Nome (ex: Sensor Teto)", text: $deviceName)
                    
                    Picker("Ambiente", selection: $selectedRoom) {
                        ForEach(RoomType.allCases, id: \.self) { room in
                            Text(room.rawValue).tag(room)
                        }
                    }
                }
                
                Section(header: Text("Método de Conexão (RF03)")) {
                    Picker("Protocolo", selection: $connectionType) {
                        Text("Wi-Fi (ESP32)").tag(ConnectionType.wifi)
                        Text("Bluetooth LE").tag(ConnectionType.bluetooth)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button(action: {
                        isScanningQR = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Escanear QR Code do Dispositivo")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        iotVM.addDevice(name: deviceName.isEmpty ? "Novo Sensor" : deviceName, roomType: selectedRoom, connection: connectionType)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Conectar ao Aplicativo")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.red)
                }
            }
            .navigationBarTitle("Novo Detector", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $isScanningQR) {
                Alert(title: Text("Leitura de QR Code"), message: Text("Código serial ESP-998877 capturado com sucesso! Configurações de Wi-Fi transferidas."), dismissButton: .default(Text("OK")) {
                    deviceName = "Detector Premium IoT"
                })
            }
        }
    }
}
