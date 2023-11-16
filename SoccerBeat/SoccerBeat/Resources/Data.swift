//
//  Data.swift
//  iOSAnimationTest
//
//  Created by jose Yun on 10/21/23.
//

import Foundation
import SwiftUI

// MARK: - Fake data for graph. Later Should be deleted or substituted by data from HealthKit - Jose

struct Series: Identifiable {
    /// The name of the play.
    let play: String
    
    /// Average daily values for each weekday.
    /// The `weekday` property is a `Date` that represents a weekday.
    let values: [(day: Date, values: Double)]
    
    /// The identifier for the series.
    var id: String { play }
}

func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

let SprintDatalast30Days = [
    (month: date(year: 2022, month: 5), values: 120, dailyAverage: 150, dailyMin: 0, dailyMax: 180),
    (month: date(year: 2022, month: 6), values: 100, dailyAverage: 127, dailyMin: 0, dailyMax: 194),
    (month: date(year: 2022, month: 7), values: 150, dailyAverage: 130, dailyMin: 0, dailyMax: 189),
    (month: date(year: 2022, month: 8), values: 140, dailyAverage: 136, dailyMin: 0, dailyMax: 193),
    (month: date(year: 2022, month: 9), values: 160, dailyAverage: 134, dailyMin: 0, dailyMax: 202),
    (month: date(year: 2022, month: 10), values: 130, dailyAverage: 131, dailyMin: 0, dailyMax: 184)
    
]

let DistanceDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 5),
        (day: date(year: 2022, month: 5, day: 3), values: 2.1),
        (day: date(year: 2022, month: 5, day: 4), values: 3.3),
        (day: date(year: 2022, month: 5, day: 5), values: 1.1),
        (day: date(year: 2022, month: 5, day: 6), values: 4.3),
        (day: date(year: 2022, month: 5, day: 7), values: 3.3),
        (day: date(year: 2022, month: 5, day: 8), values: 1.1),
        (day: date(year: 2022, month: 5, day: 9), values: 2.3),
        (day: date(year: 2022, month: 5, day: 10), values: 2.5)
    ])
]

let SpeedDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 24),
        (day: date(year: 2022, month: 5, day: 3), values: 18),
        (day: date(year: 2022, month: 5, day: 4), values: 22),
        (day: date(year: 2022, month: 5, day: 5), values: 16),
        (day: date(year: 2022, month: 5, day: 6), values: 15),
        (day: date(year: 2022, month: 5, day: 7), values: 17),
        (day: date(year: 2022, month: 5, day: 8), values: 19),
        (day: date(year: 2022, month: 5, day: 9), values: 21),
        (day: date(year: 2022, month: 5, day: 10), values: 22)
    ])
]

let heartBeatDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 110),
        (day: date(year: 2022, month: 5, day: 3), values: 140),
        (day: date(year: 2022, month: 5, day: 4), values: 166),
        (day: date(year: 2022, month: 5, day: 5), values: 169),
        (day: date(year: 2022, month: 5, day: 6), values: 185),
        (day: date(year: 2022, month: 5, day: 7), values: 171),
        (day: date(year: 2022, month: 5, day: 8), values: 194),
        (day: date(year: 2022, month: 5, day: 9), values: 137),
        (day: date(year: 2022, month: 5, day: 10), values: 145)
    ])
]

let sprintCountDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 4),
        (day: date(year: 2022, month: 5, day: 3), values: 6),
        (day: date(year: 2022, month: 5, day: 4), values: 6),
        (day: date(year: 2022, month: 5, day: 5), values: 9),
        (day: date(year: 2022, month: 5, day: 6), values: 5),
        (day: date(year: 2022, month: 5, day: 7), values: 1),
        (day: date(year: 2022, month: 5, day: 8), values: 8),
        (day: date(year: 2022, month: 5, day: 9), values: 3),
        (day: date(year: 2022, month: 5, day: 10), values: 7)
    ])
]

let HeartBeatlast12Months = [
    (month: date(year: 2022, month: 5), values: 395, dailyAverage: 127, dailyMin: 89, dailyMax: 103),
    (month: date(year: 2022, month: 6), values: 404, dailyAverage: 130, dailyMin: 78, dailyMax: 189),
    (month: date(year: 2022, month: 7), values: 393, dailyAverage: 131, dailyMin: 41, dailyMax: 144),
    (month: date(year: 2022, month: 8), values: 421, dailyAverage: 136, dailyMin: 56, dailyMax: 193),
    (month: date(year: 2022, month: 9), values: 400, dailyAverage: 134, dailyMin: 104, dailyMax: 202),
    (month: date(year: 2022, month: 10), values: 399, dailyAverage: 129, dailyMin: 84, dailyMax: 200)
]
