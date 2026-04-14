//
//  HeartRate.swift
//  SoccerBeat
//
//  Created by Gucci on 8/17/24.
//

import Foundation

struct HeartRate: Codable {
    let name: String
    let heartRate: HeartRateDetails

    struct HeartRateDetails: Codable {
        let penaltyKick: String
        let gameWinningGoal: String

        enum CodingKeys: String, CodingKey {
            case penaltyKick = "penalty_kick"
            case gameWinningGoal = "game_winning_goal"
        }
    }
}

struct HeartRateLoaded: Codable {
    let players: [HeartRate]
}
