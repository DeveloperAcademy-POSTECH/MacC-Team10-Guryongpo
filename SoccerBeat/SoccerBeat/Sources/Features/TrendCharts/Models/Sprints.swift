//
//  Sprints.swift
//  SoccerBeat
//
//  Created by Gucci on 8/17/24.
//

import Foundation

struct Sprints: Codable {
    let name: String
    let sprintCount: String

    enum CodingKeys: String, CodingKey {
        case name
        case sprintCount = "sprint_count"
    }
}

struct SprintLoaded: Codable {
    let players: [Sprints]
}
