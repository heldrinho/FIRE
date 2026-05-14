//
//  User.swift
//  FIRE
//
//  Created by Helder Filipe on 14/05/26.
//
import Foundation

// MARK: - Perfil de Usuário
enum UserRole: String, Codable {
    case resident = "Residencial"
    case admin = "Administrador"
    case technician = "Técnico"
}

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var role: UserRole
    var familyMembers: [String] // IDs de familiares compartilhados
}

// MARK: - Ambiente / Cômodo (RF07)
enum RoomType: String, Codable, CaseIterable {
    case kitchen = "Cozinha"
    case livingRoom = "Sala"
    case bedroom = "Quarto"
    case garage = "Garagem"
    case other = "Outro"
}

struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RoomType
}

// MARK: - Dispositivo / Sensor IoT (RF04)
enum ConnectionType: String, Codable {
    case wifi = "Wi-Fi"
    case bluetooth = "Bluetooth"
}

enum DeviceStatus: String, Codable {
    case online = "Online"
    case offline = "Offline"
    case alert = "Em Alerta"
}

struct Device: Identifiable, Codable {
    let id: UUID
    var name: String
    var roomId: UUID
    var temperature: Double
    var smokeLevel: Double // Porcentagem (0 a 100)
    var batteryLevel: Int // 0 a 100
    var status: DeviceStatus
    var connectionType: ConnectionType
    var lastUpdated: Date
}

// MARK: - Histórico de Ocorrências (RF06)
enum AlertType: String, Codable {
    case smoke = "Fumaça Detectada"
    case fire = "Incêndio"
    case lowBattery = "Bateria Baixa"
    case disconnected = "Desconectado"
    case test = "Teste Remoto"
}

struct AlertEvent: Identifiable, Codable {
    let id: UUID
    let deviceId: UUID
    let deviceName: String
    let type: AlertType
    let timestamp: Date
    let durationSeconds: Int
}
