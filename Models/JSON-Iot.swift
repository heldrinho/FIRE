//
//  JSON-Iot.swift
//  FIRE
//
//  Created by Turma01-8 on 18/05/26.
//

import Foundation

struct NodeRedResponse: Decodable {
    let id: String?
    let rev: String?
    let mac: String?         // <-- Essa linha TEM que estar aqui
    let temperatura: Double
    let gas: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case mac             // <-- E essa também!
        case temperatura
        case gas
    }
}

