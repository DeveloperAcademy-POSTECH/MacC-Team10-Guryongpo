//
//  DistancePer90.swift
//  SoccerBeat
//
//  Created by Gucci on 8/17/24.
//

import Foundation

struct DistancePer90min: Codable {
    let name: String
    let distancePer90min: String

    enum CodingKeys: String, CodingKey {
        case name
        case distancePer90min = "distance_per_90min"
    }
}

struct DistanceLoaded: Codable {
    let players: [DistancePer90min]
}
