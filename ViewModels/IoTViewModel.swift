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
    
    // Variáveis de Erro do QR Code
    @Published var showQRError: Bool = false
    @Published var qrErrorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let nodeRedURL = URL(string: "http://192.168.128.118:1880/leitura")!
    private var macConectado: String? = nil
    
    private let devicesKey = "saved_devices"
    private let roomsKey = "saved_rooms"
    private let historyKey = "saved_history"
    private let macKey = "saved_mac"
    
    init() {
        if !loadSavedData() {
            loadInitialData()
        }
        startRealTimeUpdates()
    }
    
    func saveData() {
        if let encodedDevices = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encodedDevices, forKey: devicesKey)
        }
        if let encodedRooms = try? JSONEncoder().encode(rooms) {
            UserDefaults.standard.set(encodedRooms, forKey: roomsKey)
        }
        if let encodedHistory = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedHistory, forKey: historyKey)
        }
        if let mac = macConectado {
            UserDefaults.standard.set(mac, forKey: macKey)
        }
    }
    
    private func loadSavedData() -> Bool {
        self.macConectado = UserDefaults.standard.string(forKey: macKey)
        
        guard let savedDevicesData = UserDefaults.standard.data(forKey: devicesKey),
              let savedRoomsData = UserDefaults.standard.data(forKey: roomsKey) else {
            return false
        }
        
        do {
            self.devices = try JSONDecoder().decode([Device].self, from: savedDevicesData)
            self.rooms = try JSONDecoder().decode([Room].self, from: savedRoomsData)
            
            if let savedHistoryData = UserDefaults.standard.data(forKey: historyKey),
               let decodedHistory = try? JSONDecoder().decode([AlertEvent].self, from: savedHistoryData) {
                self.history = decodedHistory
            }
            return true
        } catch {
            return false
        }
    }
    
    private func loadInitialData() {
        let kitchenId = UUID()
        let livingRoomId = UUID()
        
        rooms = [
            Room(id: kitchenId, name: "Cozinha Principal", type: .kitchen),
            Room(id: livingRoomId, name: "Sala de Estar", type: .livingRoom)
        ]
        
        let dev1 = Device(id: UUID(), name: "Sensor", roomId: kitchenId, temperature: 0, smokeLevel: 0, batteryLevel: 100, status: .offline, connectionType: .wifi, lastUpdated: Date())
        
        devices = [dev1]
        
        history = [
            AlertEvent(id: UUID(), deviceId: dev1.id, deviceName: dev1.name, type: .test, timestamp: Date().addingTimeInterval(-86400), durationSeconds: 10),
        ]
        
        saveData()
    }
    
    func startRealTimeUpdates() {
        timer?.invalidate()
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
                    print("Erro de conexão local: \(error.localizedDescription)")
                    if let index = self.devices.indices.last {
                        self.devices[index].status = .offline
                    }
                }
            }, receiveValue: { [weak self] responseList in
                self?.updateDeviceData(with: responseList)
            })
            .store(in: &cancellables)
    }
    
    private func updateDeviceData(with fullList: [NodeRedResponse]) {
        if fullList.isEmpty { return }
        
        if self.macConectado == nil {
            self.macConectado = fullList.last?.mac
        }
        
        guard let macAtual = self.macConectado else { return }
        
        let leiturasDaMinhaPlaca = fullList.filter { $0.mac == macAtual }
        guard let ultimaLeitura = leiturasDaMinhaPlaca.last else { return }
        
        guard let index = self.devices.indices.last else { return }
        
        let smokePercentage = (ultimaLeitura.gas / 1024.0) * 100.0
        
        self.devices[index].temperature = ultimaLeitura.temperatura
        self.devices[index].smokeLevel = smokePercentage
        self.devices[index].status = .online
        self.devices[index].lastUpdated = Date()
        
        evaluateEmergencyState(temp: ultimaLeitura.temperatura, gas: ultimaLeitura.gas)
        
        if ultimaLeitura.temperatura > 50.0 || ultimaLeitura.gas > 800 {
            if self.activeEmergency == nil {
                let newAlert = AlertEvent(id: UUID(), deviceId: self.devices[index].id, deviceName: self.devices[index].name, type: .fire, timestamp: Date(), durationSeconds: 0)
                self.activeEmergency = newAlert
                self.history.insert(newAlert, at: 0)
                self.devices[index].status = .alert
                saveData()
            }
        } else {
            if self.activeEmergency != nil {
                self.activeEmergency = nil
                self.devices[index].status = .online
                saveData()
            }
        }
    }
    
    func evaluateEmergencyState(temp: Double, gas: Double) {
        if temp >= 45.0 && gas >= 650.0 {
            sendPushNotification(title: "🚨 INCÊNDIO CONFIRMADO", body: "Fogo ativo e fumaça detectados! Evacue imediatamente!")
        } else if temp >= 45.0 && gas <= 600.0 {
            sendPushNotification(title: "🔥 ALERTA TÉRMICO", body: "Calor excessivo detectado na sala. Verifique o local.")
        } else if temp <= 30.0 && gas >= 650.0 {
            sendPushNotification(title: "⚠️ ALERTA DE FUMAÇA/GÁS", body: "Nível alto de fumaça ou gás detectado. Verifique preventivamente.")
        } else if temp <= 30.0 && gas <= 600.0 {
            print("Status: Ambiente seguro e climatizado.")
        }
    }
    
    func sendPushNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func addDevice(name: String, roomType: RoomType, connection: ConnectionType, scannedCode: String? = nil) {
            
            // Zera qualquer erro de forma IMEDIATA (sem o DispatchQueue)
            self.showQRError = false
            self.qrErrorMessage = ""
            
            if let qrText = scannedCode, !qrText.isEmpty {
                
                // Verifica o prefixo exato que você pediu
                if qrText.hasPrefix("FIRE_ESP:") {
                    let macPuro = qrText.replacingOccurrences(of: "FIRE_ESP:", with: "")
                    
                    if isValidMACAddress(macPuro) {
                        self.macConectado = macPuro
                        print("✅ Sucesso: Placa FIRE genuína adicionada! MAC: \(macPuro)")
                    } else {
                        self.qrErrorMessage = "Assinatura reconhecida, mas o MAC (\(macPuro)) é inválido."
                        self.showQRError = true
                        return
                    }
                } else {
                    self.qrErrorMessage = "QR Code Inválido. Falta a assinatura do sistema FIRE_ESP."
                    self.showQRError = true
                    return
                }
            }
            
            // ... (O resto da função continua exatamente igual)
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
        saveData()
    }
    
    private func isValidMACAddress(_ mac: String) -> Bool {
        let macRegex = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
        let macPredicate = NSPredicate(format: "SELF MATCHES %@", macRegex)
        return macPredicate.evaluate(with: mac)
    }
}

