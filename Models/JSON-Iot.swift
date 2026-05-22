//
//  JSON-Iot.swift
//  FIRE
//
//  Created by Turma01-8 on 18/05/26.
//

import Foundation

struct NodeRedResponse: Codable {
    let id: String?
    let rev: String?
    let mac: String?
    let temperatura: Double
    let gas: Double
    let data_hora: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case mac             // <-- E essa também!
        case temperatura
        case gas
        case data_hora
    }
}

