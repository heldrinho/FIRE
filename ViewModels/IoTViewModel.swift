//
//  IoTViewModel.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import Foundation
import SwiftUI
import Combine // ⚠️ Também necessário aqui

class IoTViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var devices: [Device] = []
    @Published var history: [AlertEvent] = []
    @Published var activeEmergency: AlertEvent?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialData()
        setupTelemetryListener()
    }
    
    private func loadInitialData() {
        let kitchenId = UUID()
        let livingRoomId = UUID()
        
        rooms = [
            Room(id: kitchenId, name: "Cozinha Principal", type: .kitchen),
            Room(id: livingRoomId, name: "Sala de Estar", type: .livingRoom)
        ]
        
        let dev1 = Device(id: UUID(), name: "Detector Cozinha", roomId: kitchenId, temperature: 24.5, smokeLevel: 2.1, batteryLevel: 92, status: .online, connectionType: .wifi, lastUpdated: Date())
        let dev2 = Device(id: UUID(), name: "Detector Sala", roomId: livingRoomId, temperature: 23.0, smokeLevel: 0.0, batteryLevel: 15, status: .online, connectionType: .wifi, lastUpdated: Date())
        
        devices = [dev1, dev2]
        
        history = [
            AlertEvent(id: UUID(), deviceId: dev1.id, deviceName: dev1.name, type: .test, timestamp: Date().addingTimeInterval(-86400), durationSeconds: 10),
            AlertEvent(id: UUID(), deviceId: dev2.id, deviceName: dev2.name, type: .lowBattery, timestamp: Date().addingTimeInterval(-3600), durationSeconds: 0)
        ]
    }
    
    private func setupTelemetryListener() {
        IoTNetworkService.shared.listenToDeviceUpdates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedDevice in
                guard let self = self else { return }
                if updatedDevice.smokeLevel > 30.0 {
                    self.triggerEmergencyAlert(for: updatedDevice)
                }
            }
            .store(in: &cancellables)
    }
    
    func triggerEmergencyAlert(for device: Device) {
        let newAlert = AlertEvent(id: UUID(), deviceId: device.id, deviceName: device.name, type: .fire, timestamp: Date(), durationSeconds: 0)
        self.activeEmergency = newAlert
        self.history.insert(newAlert, at: 0)
    }
    
    func addDevice(name: String, roomType: RoomType, connection: ConnectionType) {
        var targetRoom = rooms.first(where: { $0.type == roomType })
        if targetRoom == nil {
            let newRoom = Room(id: UUID(), name: roomType.rawValue, type: roomType)
            rooms.append(newRoom)
            targetRoom = newRoom
        }
        
        let newDevice = Device(id: UUID(), name: name, roomId: targetRoom!.id, temperature: 25.0, smokeLevel: 0.0, batteryLevel: 100, status: .online, connectionType: connection, lastUpdated: Date())
        devices.append(newDevice)
    }
    
    func testAlarm(device: Device) {
        IoTNetworkService.shared.triggerRemoteTest(for: device.id) { success in
            DispatchQueue.main.async {
                let testEvent = AlertEvent(id: UUID(), deviceId: device.id, deviceName: device.name, type: .test, timestamp: Date(), durationSeconds: 5)
                self.history.insert(testEvent, at: 0)
            }
        }
    }
}
