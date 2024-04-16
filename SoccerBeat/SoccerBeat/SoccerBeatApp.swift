//
//  SoccerBeatApp.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeatApp: App {
    @StateObject var soundManager = SoundManager()
    @StateObject var healthInteracter = HealthInteractor.shared
    @StateObject var profileModel = ProfileModel(healthInteractor: HealthInteractor.shared)
    @State private var noHealth: Bool
    @State private var noLocation: Bool
    
    init() {
        self.noHealth = HealthInteractor.shared.haveNoHealthAuthorization()
        self.noLocation = HealthInteractor.shared.haveNoLocationAuthorization()
    }
    var body: some Scene {
        WindowGroup {
            //             if Authorization == sharingDenied, 명시적으로 거절함.
            Group {
                if noHealth {
                    NoAuthorizationView(requestingAuth: .health)
                } else if noLocation {
                    NoAuthorizationView(requestingAuth: .location)
                }
                
                if !noHealth && !noLocation {
                    ContentView()
                }
            }
            .environmentObject(soundManager)
            .environmentObject(healthInteracter)
            .environmentObject(profileModel)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                noHealth = healthInteracter.haveNoHealthAuthorization()
                noLocation = healthInteracter.haveNoLocationAuthorization()
                Task {
                    if !noHealth && !noLocation {
                        await self.healthInteracter.fetchWorkoutData()
                    }
                }
            }
            .task {
                healthInteracter.requestAuthorization()
            }
            .onReceive(healthInteracter.authSuccess) {
                Task { await healthInteracter.fetchWorkoutData() }
            }
        }
    }
}
