//
//  BadgeImages.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 11/20/23.
//

import Foundation

let BadgeImageDictionary: [[Int: String]] = [[
    -1: "",
     0: "Distance_Unlocked_1",
     1: "Distance_Unlocked_2",
     2: "Distance_Unlocked_3",
     3: "Distance_Unlocked_4"
], [
    -1: "",
     0: "Sprint_Unlocked_1",
     1: "Sprint_Unlocked_2",
     2: "Sprint_Unlocked_3",
     3: "Sprint_Unlocked_4"
], [
    -1: "",
     0: "Velocity_Unlocked_1",
     1: "Velocity_Unlocked_2",
     2: "Velocity_Unlocked_3",
     3: "Velocity_Unlocked_4"
]
]

let ShortenedBadgeImageDictionary: [[Int: String]] = [[
    -1: "",
     0: "Distance_Shortened_1",
     1: "Distance_Shortened_2",
     2: "Distance_Shortened_3",
     3: "Distance_Shortened_4"
], [
    -1: "",
     0: "Sprint_Shortened_1",
     1: "Sprint_Shortened_2",
     2: "Sprint_Shortened_3",
     3: "Sprint_Shortened_4"
], [
    -1: "",
     0: "Velocity_Shortened_1",
     1: "Velocity_Shortened_2",
     2: "Velocity_Shortened_3",
     3: "Velocity_Shortened_4"
]
]

let badgeUnlockedImages: [[String]] = [
    ["Distance_Unlocked_1", "Distance_Unlocked_2", "Distance_Unlocked_3", "Distance_Unlocked_4"],
    ["Sprint_Unlocked_1", "Sprint_Unlocked_2", "Sprint_Unlocked_3", "Sprint_Unlocked_4"],
    ["Velocity_Unlocked_1", "Velocity_Unlocked_2", "Velocity_Unlocked_3", "Velocity_Unlocked_4"]
]

let badgeLockedImages: [[String]] = [
    ["Distance_Locked_1", "Distance_Locked_2", "Distance_Locked_3", "Distance_Locked_4"],
    ["Sprint_Locked_1", "Sprint_Locked_2", "Sprint_Locked_3", "Sprint_Locked_4"],
    ["Velocity_Locked_1", "Velocity_Locked_2", "Velocity_Locked_3", "Velocity_Locked_4"]
]

let badgeInfo: [[String]] = [
    ["뛴거리\n1 km 초과",
     "뛴거리\n2 km 초과",
     "뛴거리\n3 km 초과",
     "뛴거리\n4 km 초과"],
    ["스프린트\n1 회 초과",
     "스프린트\n3 회 초과",
     "스프린트\n5 회 초과",
     "스프린트\n7 회 초과"],
    ["최고속도\n10 km/h 초과",
     "최고속도\n15 km/h 초과",
     "최고속도\n20 km/h 초과",
     "최고속도\n25 km/h 초과"]
]
