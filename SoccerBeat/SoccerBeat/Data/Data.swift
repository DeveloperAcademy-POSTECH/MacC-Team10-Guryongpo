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
    let values: [(day: Date, values: Int)]
    
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
    (month: date(year: 2022, month: 10), values: 130, dailyAverage: 131, dailyMin: 0, dailyMax: 184),
    
]

let DistanceDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 54),
        (day: date(year: 2022, month: 5, day: 3), values: 42),
        (day: date(year: 2022, month: 5, day: 4), values: 88),
        (day: date(year: 2022, month: 5, day: 5), values: 49),
        (day: date(year: 2022, month: 5, day: 6), values: 42),
        (day: date(year: 2022, month: 5, day: 7), values: 125)
    ])
]

let SpeedDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 42),
        (day: date(year: 2022, month: 5, day: 3), values: 54),
        (day: date(year: 2022, month: 5, day: 4), values: 42),
        (day: date(year: 2022, month: 5, day: 5), values: 88),
        (day: date(year: 2022, month: 5, day: 6), values: 39),
        (day: date(year: 2022, month: 5, day: 7), values: 49)
    ])
]

let HeartBeatlast12Months = [
    (month: date(year: 2022, month: 5), values: 395, dailyAverage: 127, dailyMin: 95, dailyMax: 194),
    (month: date(year: 2022, month: 6), values: 404, dailyAverage: 130, dailyMin: 96, dailyMax: 189),
    (month: date(year: 2022, month: 7), values: 393, dailyAverage: 131, dailyMin: 101, dailyMax: 184),
    (month: date(year: 2022, month: 8), values: 421, dailyAverage: 136, dailyMin: 96, dailyMax: 193),
    (month: date(year: 2022, month: 9), values: 400, dailyAverage: 134, dailyMin: 104, dailyMax: 202),
    (month: date(year: 2022, month: 10), values: 399, dailyAverage: 129, dailyMin: 96, dailyMax: 200)
]
