//
//  SoccerBeatApp.swift
//  SoccerBeat Watch App
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeat_Watch_AppApp: App {
    
    @StateObject private var workoutManager = DIContianer.makeWorkoutManager()
    @StateObject private var matricsIndicator = DIContianer.makeMatricsIndicator()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
            .environmentObject(matricsIndicator)
        }
    }
}

final class DIContianer {
    static private(set) var matrics: MatricsIndicator?
    
    static func makeWorkoutManager() -> WorkoutManager {
        if let matrics = self.matrics {
            return WorkoutManager(matrics: matrics)
        } else {
            let matrics = makeMatricsIndicator()
            self.matrics = matrics
            return WorkoutManager(matrics: matrics)
        }
    }
    
    static func makeMatricsIndicator() -> MatricsIndicator {
        if let matrics = self.matrics {
            return matrics
        }
        let matrics = MatricsIndicator()
        self.matrics = matrics
        return matrics
    }
}
