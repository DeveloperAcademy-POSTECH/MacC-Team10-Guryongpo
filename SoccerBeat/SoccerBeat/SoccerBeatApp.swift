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
    
    var body: some Scene {
        WindowGroup {
//             if Authorization == sharingDenied, 명시적으로 거절함.
            if healthInteracter.haveNoHealthAuthorization() {
                GuideAuthorizationView(requestingAuth: .health)
            } else if healthInteracter.haveNoLocationAuthorization() {
                GuideAuthorizationView(requestingAuth: .location)
            } else {
              ContentView()
                .environmentObject(soundManager)
                .environmentObject(healthInteracter)
                .environmentObject(profileModel)
            }
        }
    }
}
