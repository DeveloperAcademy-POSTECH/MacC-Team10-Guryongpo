//
//  SoccerBeatApp.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI
import HealthKit
import HealthKitUI
import os

@main
struct SoccerBeatApp: App {
    @StateObject var soundManager = SoundManager()
    @StateObject var healthInteracter = HealthInteractor.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(soundManager)
                .environmentObject(healthInteracter)
        }
    }
}
