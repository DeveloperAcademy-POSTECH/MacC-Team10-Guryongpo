//
//  TopSpeed.swift
//  SoccerBeat
//
//  Created by Gucci on 8/17/24.
//

import Foundation

struct TopSpeed: Codable {
    let name: String
    let topSpeed: String

    enum CodingKeys: String, CodingKey {
        case name
        case topSpeed = "top_speed"
    }
}

struct TopSpeedLoaded: Codable {
    let players: [TopSpeed]
}
