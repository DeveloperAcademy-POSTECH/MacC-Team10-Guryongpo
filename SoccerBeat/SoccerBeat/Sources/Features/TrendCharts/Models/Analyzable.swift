//
//  Analyzable.swift
//  SoccerBeat
//
//  Created by Gucci on 11/14/23.
//

import Foundation

protocol Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData
    func minimum(of workouts: [WorkoutData]) -> WorkoutData
    func average(of workouts: [WorkoutData]) -> Double
}
