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
import UserNotifications

class IoTViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var devices: [Device] = []
    @Published var history: [AlertEvent] = []
    @Published var activeEmergency: AlertEvent?
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    // URL do seu Node-RED
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
        
        // Dispositivo criado com o nome "Sensor"
        let dev1 = Device(id: UUID(), name: "Sensor", roomId: kitchenId, temperature: 0, smokeLevel: 0, batteryLevel: 100, status: .offline, connectionType: .wifi, lastUpdated: Date())
        
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
//        URLSession.shared.dataTaskPublisher(for: nodeRedURL)
//            .map { $0.data }
//            .decode(type: [NodeRedResponse].self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    print("Erro Node-RED: \(error.localizedDescription)")
//                    // Se falhar a conexão, marca o sensor como offline
//                    if let index = self.devices.firstIndex(where: { $0.name == "Sensor" }) {
//                        self.devices[index].status = .offline
//                    }
//                }
//            }, receiveValue: { [weak self] responseList in
//                self?.updateDeviceData(with: responseList)
//            })
//            .store(in: &cancellables)
            let leituraFake = NodeRedResponse(id: nil,
                                              rev: nil,
                                              mac: self.macConectado ?? "MAC_TESTE",
                    temperatura: 55.0,
                    gas: 900.0,
                )
        self.updateDeviceData(with: [leituraFake])
        
    }
    
    func sendPushNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao enviar notificação: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateDeviceData(with fullList: [NodeRedResponse]) {
        // Se ainda não temos o MAC, tentamos pegar o último que chegou no servidor
        if self.macConectado == nil {
            self.macConectado = fullList.last?.mac
        }
        
        guard let macAtual = self.macConectado else { return }
        
        // Filtra leituras da placa específica
        let leiturasDaMinhaPlaca = fullList.filter { $0.mac == macAtual }
        guard let ultimaLeitura = leiturasDaMinhaPlaca.last else { return }
        
        // Procura o dispositivo pelo nome correto ("Sensor")
        guard let index = self.devices.firstIndex(where: { $0.name == "Sensor" }) else { return }
        
        let smokePercentage = (ultimaLeitura.gas / 1024.0) * 100.0
        
        // Atualiza variáveis do dispositivo
        self.devices[index].temperature = ultimaLeitura.temperatura
        self.devices[index].smokeLevel = smokePercentage
        self.devices[index].status = .online
        self.devices[index].lastUpdated = Date()
        
        // 1. Avalia se deve enviar Notificação Push
        evaluateEmergencyState(temp: ultimaLeitura.temperatura, gas: ultimaLeitura.gas)
        
        // 2. Atualiza o estado visual de emergência (Interface Vermelha)
        // Regra: Temperaturas críticas ou Gás muito alto
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
    
    // Função de lógica de decisão baseada nos "dados hacka"
    func evaluateEmergencyState(temp: Double, gas: Double) {
        
        // 🔴 Categoria 4: CRÍTICO (Incêndio Confirmado)
        if temp >= 45.0 && gas >= 650.0 {
            sendPushNotification(
                title: "🚨 INCÊNDIO CONFIRMADO",
                body: "Fogo ativo e fumaça detectados! Evacue imediatamente!"
            )
            
        // 🟠 Categoria 3: ANOMALIA TÉRMICA (Calor sem fumaça)
        } else if temp >= 45.0 && gas <= 600.0 {
            sendPushNotification(
                title: "🔥 ALERTA TÉRMICO",
                body: "Calor excessivo detectado na sala. Verifique o local."
            )
            
        // 🟡 Categoria 2: ALERTA (Fumaça/Vazamento)
        } else if temp <= 30.0 && gas >= 650.0 {
            sendPushNotification(
                title: "⚠️ ALERTA DE FUMAÇA/GÁS",
                body: "Nível alto de fumaça ou gás detectado. Verifique preventivamente."
            )
            
        // 🟢 Categoria 1: NORMAL
        } else if temp <= 30.0 && gas <= 600.0 {
            print("Status: Ambiente seguro e climatizado.")
        }
    }
    
    func addDevice(name: String, roomType: RoomType, connection: ConnectionType, scannedCode: String? = nil) {
        if let mac = scannedCode, !mac.isEmpty {
            self.macConectado = mac
        }
        
        var targetRoom = rooms.first(where: { $0.type == roomType })
        if targetRoom == nil {
            let newRoom = Room(id: UUID(), name: roomType.rawValue, type: roomType)
            rooms.append(newRoom)
            targetRoom = newRoom
        }
        
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
        saveData()
    }
    
    func testAlarm(device: Device) {
        let testEvent = AlertEvent(id: UUID(), deviceId: device.id, deviceName: device.name, type: .test, timestamp: Date(), durationSeconds: 5)
        self.history.insert(testEvent, at: 0)
    }
}
