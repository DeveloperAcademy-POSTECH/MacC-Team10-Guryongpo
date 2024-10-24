//
//  SoccerBeatApp.swift
//  SoccerBeat Watch App
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeat_WatchApp: App {
    
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var matricsIndicator = DIContianer.makeMatricsIndicator()
    @State var triggerHealthKitAuthorization = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .environmentObject(workoutManager)
            .environmentObject(matricsIndicator)
            .environment(\.locale, .current)
        }
    }
}
