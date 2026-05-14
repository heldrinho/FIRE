//
//  IoTNetworkService.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import Foundation
import Combine

class IoTNetworkService {
    static let shared = IoTNetworkService()
    private init() {}
    
    // Simula o envio de um comando para o ESP32 (RF09 - Teste Remoto)
    func triggerRemoteTest(for deviceId: UUID, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Em produção: requisição HTTPS/MQTT para o Broker
            completion(true)
        }
    }
    
    // Simula a escuta contínua de eventos do servidor (RNF01 - Tempo de resposta < 5s)
    func listenToDeviceUpdates() -> AnyPublisher<Device, Never> {
        let subject = PassthroughSubject<Device, Never>()
        
        // Simulação de telemetria chegando a cada 4 segundos
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            let mockUpdate = Device(
                id: UUID(), // Idealmente o ID de um device existente
                name: "Sensor Cozinha",
                roomId: UUID(),
                temperature: Double.random(in: 22.0...26.0),
                smokeLevel: Double.random(in: 0.0...5.0),
                batteryLevel: Int.random(in: 80...100),
                status: .online,
                connectionType: .wifi,
                lastUpdated: Date()
            )
            subject.send(mockUpdate)
        }
        
        return subject.eraseToAnyPublisher()
    }
}
