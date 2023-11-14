//
//  SoccerBeatApp.swift
//  SoccerBeat Watch App
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeat_Watch_AppApp: App {
    @StateObject private 
    var workoutManager = WorkoutManager.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }
    }
}
