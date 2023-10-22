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
    (day: date(year: 2022, month: 5, day: 8), values: 168),
    (day: date(year: 2022, month: 5, day: 9), values: 117),
    (day: date(year: 2022, month: 5, day: 10), values: 119),
    (day: date(year: 2022, month: 5, day: 11), values: 106),
    (day: date(year: 2022, month: 5, day: 12), values: 119),
    (day: date(year: 2022, month: 5, day: 13), values: 109),
    (day: date(year: 2022, month: 5, day: 14), values: 168),
    (day: date(year: 2022, month: 5, day: 15), values: 106),
    (day: date(year: 2022, month: 5, day: 16), values: 117),
    (day: date(year: 2022, month: 5, day: 17), values: 109)
]

let DistanceDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 54),
        (day: date(year: 2022, month: 5, day: 3), values: 42),
        (day: date(year: 2022, month: 5, day: 4), values: 88),
        (day: date(year: 2022, month: 5, day: 5), values: 49),
        (day: date(year: 2022, month: 5, day: 6), values: 42),
        (day: date(year: 2022, month: 5, day: 7), values: 125),
        (day: date(year: 2022, month: 5, day: 8), values: 67)

    ])
]

let SpeedDummyData: [Series] = [
    .init(play: "", values: [
        (day: date(year: 2022, month: 5, day: 2), values: 42),
        (day: date(year: 2022, month: 5, day: 3), values: 54),
        (day: date(year: 2022, month: 5, day: 4), values: 42),
        (day: date(year: 2022, month: 5, day: 5), values: 88),
        (day: date(year: 2022, month: 5, day: 6), values: 39),
        (day: date(year: 2022, month: 5, day: 7), values: 49),
        (day: date(year: 2022, month: 5, day: 8), values: 67)
    ])
]

let HeartBeatlast12Months = [
    (month: date(year: 2021, month: 7), values: 3952, dailyAverage: 127, dailyMin: 95, dailyMax: 194),
    (month: date(year: 2021, month: 8), values: 4044, dailyAverage: 130, dailyMin: 96, dailyMax: 189),
    (month: date(year: 2021, month: 9), values: 3930, dailyAverage: 131, dailyMin: 101, dailyMax: 184),
    (month: date(year: 2021, month: 10), values: 4217, dailyAverage: 136, dailyMin: 96, dailyMax: 193),
    (month: date(year: 2021, month: 11), values: 4006, dailyAverage: 134, dailyMin: 104, dailyMax: 202),
    (month: date(year: 2021, month: 12), values: 3994, dailyAverage: 129, dailyMin: 96, dailyMax: 190),
    (month: date(year: 2022, month: 1), values: 4202, dailyAverage: 136, dailyMin: 96, dailyMax: 203),
    (month: date(year: 2022, month: 2), values: 3749, dailyAverage: 134, dailyMin: 98, dailyMax: 200),
    (month: date(year: 2022, month: 3), values: 4329, dailyAverage: 140, dailyMin: 104, dailyMax: 218),
    (month: date(year: 2022, month: 4), values: 4084, dailyAverage: 136, dailyMin: 93, dailyMax: 221),
    (month: date(year: 2022, month: 5), values: 4559, dailyAverage: 147, dailyMin: 104, dailyMax: 208),
    (month: date(year: 2022, month: 6), values: 1023, dailyAverage: 170, dailyMin: 120, dailyMax: 170)
]
