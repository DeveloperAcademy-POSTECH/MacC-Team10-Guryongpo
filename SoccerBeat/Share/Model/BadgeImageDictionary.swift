//
//  BadgeImages.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 11/20/23.
//

import Foundation

let BadgeImageDictionary: [[Int: String]] = [[
    -1: "",
     0: "DistanceFirstUnlocked",
     1: "DistanceSecondUnlocked",
     2: "DistanceThirdUnlocked",
     3: "DistanceFourthUnlocked"
], [
    -1: "",
     0: "SprintFirstUnlocked",
     1: "SprintSecondUnlocked",
     2: "SprintThirdUnlocked",
     3: "SprintFourthUnlocked"
], [
    -1: "",
     0: "VelocityFirstUnlocked",
     1: "VelocitySecondUnlocked",
     2: "VelocityThirdUnlocked",
     3: "VelocityFourthUnlocked"
]
]

let badgeUnlockedImages: [[String]] = [
    ["DistanceFirstUnlocked", "DistanceSecondUnlocked", "DistanceThirdUnlocked", "DistanceFourthUnlocked"],
    ["SprintFirstUnlocked", "SprintSecondUnlocked", "SprintThirdUnlocked", "SprintFourthUnlocked"],
    ["VelocityFirstUnlocked", "VelocitySecondUnlocked", "VelocityThirdUnlocked", "VelocityFourthUnlocked"]
]

let badgeLockedImages: [[String]] = [
    ["DistanceFirstLocked", "DistanceSecondLocked", "DistanceThirdLocked", "DistanceFourthLocked"],
    ["SprintFirstLocked", "SprintSecondLocked", "SprintThirdLocked", "SprintFourthLocked"],
    ["VelocityFirstLocked", "VelocitySecondLocked", "VelocityThirdLocked", "VelocityFourthLocked"]
]

let badgeInfo: [[String]] = [
    ["뛴거리\n1 km 초과", "뛴거리\n2 km 초과", "뛴거리\n3 km 초과", "뛴거리\n4 km 초과"],
    ["스프린트\n2 회 초과", "스프린트\n4 회 초과", "스프린트\n6 회 초과", "스프린트\n8 회 초과"],
    ["최고속도\n10 km/h 초과", "최고속도\n15 km/h 초과", "최고속도\n20 km/h 초과", "최고속도\n25 km/h 초과"]
]
