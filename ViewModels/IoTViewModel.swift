//
//  IoTViewModel.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//  Modified by joaoatilamonteiro on 18/05/26
//

import Foundation
import SwiftUI
import Combine

class IoTViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var devices: [Device] = []
    @Published var history: [AlertEvent] = []
    @Published var activeEmergency: AlertEvent?
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let nodeRedURL = URL(string: "http://192.168.128.118:1880/leitura")!
    
    private var macConectado: String? = nil
    // Chaves para o UserDefaults
    private let devicesKey = "saved_devices"
    private let roomsKey = "saved_rooms"
    
    init() {
        loadInitialData()
        startRealTimeUpdates()
    }
    func saveData() {
        if let encodedDevices = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encodedDevices, forKey: devicesKey)
        }
        if let encodedRooms = try? JSONEncoder().encode(rooms) {
            UserDefaults.standard.set(encodedRooms, forKey: roomsKey)
        }
    }
    
    private func loadInitialData() {
        let kitchenId = UUID()
        let livingRoomId = UUID()
        
        rooms = [
            Room(id: kitchenId, name: "Cozinha Principal", type: .kitchen),
            Room(id: livingRoomId, name: "Sala de Estar", type: .livingRoom)
        ]
        
        let dev1 = Device(id: UUID(), name: "Sensor", roomId: kitchenId, temperature: 0, smokeLevel: 0, batteryLevel: 0, status: .offline, connectionType: .wifi, lastUpdated: Date())
        
        
        devices = [dev1]
        
        history = [
            AlertEvent(id: UUID(), deviceId: dev1.id, deviceName: dev1.name, type: .test, timestamp: Date().addingTimeInterval(-86400), durationSeconds: 10),
        ]
    }
    
    func startRealTimeUpdates() {
        timer?.invalidate()
        // Busca os dados a cada 2 segundos
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.fetchSensorData()
        }
    }
    
    private func fetchSensorData() {
        URLSession.shared.dataTaskPublisher(for: nodeRedURL)
            .map { $0.data }
            .decode(type: [NodeRedResponse].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Erro Node-RED: \(error.localizedDescription)")
                    if let index = self.devices.firstIndex(where: { $0.name == "Detector Cozinha" }) {
                        self.devices[index].status = .offline
                    }
                }
            }, receiveValue: { [weak self] responseList in
                self?.updateDeviceData(with: responseList)
            })
            .store(in: &cancellables)
    }
    
    private func updateDeviceData(with fullList: [NodeRedResponse]) {
        // NOVIDADE: Se o app ainda não sabe o MAC, ele pega da leitura mais recente do servidor!
        //if self.macConectado == nil {
          //  self.macConectado = fullList.last?.mac
        //}
        
        // Garante que conseguimos descobrir um MAC antes de continuar
        guard let macAtual = self.macConectado else { return }
        
        // 1. Filtra a lista gigante do Node-RED usando o MAC que o app acabou de descobrir
        let leiturasDaMinhaPlaca = fullList.filter { $0.mac == macAtual }
        
        // 2. Pega a ÚLTIMA leitura da lista
        guard let ultimaLeitura = leiturasDaMinhaPlaca.last else { return }
        
        // 3. Acha o "Detector Cozinha" na tela do celular
        guard let index = self.devices.firstIndex(where: { $0.name == "Detector Cozinha" }) else { return }
        
        // Converte o valor bruto do gás para porcentagem
        let smokePercentage = (ultimaLeitura.gas / 1024.0) * 100.0
        
        // Atualiza a interface
        self.devices[index].temperature = ultimaLeitura.temperatura
        self.devices[index].smokeLevel = smokePercentage
        self.devices[index].status = .online
        self.devices[index].lastUpdated = Date()
        
        // Regra de Alerta (Temperaturas acima de 50C ou Gás muito alto disparam a interface vermelha)
        if ultimaLeitura.temperatura > 50.0 || ultimaLeitura.gas > 800 {
            if self.activeEmergency == nil {
                let newAlert = AlertEvent(id: UUID(), deviceId: self.devices[index].id, deviceName: self.devices[index].name, type: .fire, timestamp: Date(), durationSeconds: 0)
                self.activeEmergency = newAlert
                self.history.insert(newAlert, at: 0)
                self.devices[index].status = .alert
            }
        } else {
            if self.activeEmergency != nil {
                self.activeEmergency = nil
                self.devices[index].status = .online
            }
        }
    }
    
    func addDevice(name: String, roomType: RoomType, connection: ConnectionType, scannedCode: String? = nil) {
        // 1. Se um código QR foi escaneado, salvamos ele na variável da classe
        if let mac = scannedCode, !mac.isEmpty {
            self.macConectado = mac
        }
        
        // 2. Lógica original de criação de ambiente
        var targetRoom = rooms.first(where: { $0.type == roomType })
        if targetRoom == nil {
            let newRoom = Room(id: UUID(), name: roomType.rawValue, type: roomType)
            rooms.append(newRoom)
            targetRoom = newRoom
        }
        
        // 3. Lógica original de criação do dispositivo
        let newDevice = Device(id: UUID(),
                               name: name,
                               roomId: targetRoom!.id,
                               temperature: 25.0,
                               smokeLevel: 0.0,
                               batteryLevel: 100,
                               status: .online,
                               connectionType: connection,
                               lastUpdated: Date())
                               
        devices.append(newDevice)
    }
    
    func testAlarm(device: Device) {
        let testEvent = AlertEvent(id: UUID(), deviceId: device.id, deviceName: device.name, type: .test, timestamp: Date(), durationSeconds: 5)
        self.history.insert(testEvent, at: 0)
    }
}
