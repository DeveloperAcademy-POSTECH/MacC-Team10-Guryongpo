//
//  SoccerBeatApp.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeatApp: App {
    @State var isShowingOnboardingView : Bool
    @StateObject var soundManager = SoundManager()
    @StateObject var healthInteracter = HealthInteractor.shared
    @StateObject var profileModel = ProfileModel(healthInteractor: HealthInteractor.shared)
    @State private var hasHealthAuthorization: Bool
    @State private var hasLocationAuthorization: Bool
    @State private var showUpdate: Bool = false
    
    
    init() {
        self.hasHealthAuthorization = HealthInteractor.shared.haveHealthAuthorization()
        self.hasLocationAuthorization = HealthInteractor.shared.hasLocationAuthorization()
        self.isShowingOnboardingView = false
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if hasHealthAuthorization && hasLocationAuthorization {
                    ContentView(isShowingOnboardingView: $isShowingOnboardingView)
                } else if !hasHealthAuthorization {
                    NoAuthorizationView(requestingAuth: .health)
                } else if !hasLocationAuthorization {
                    NoAuthorizationView(requestingAuth: .location)
                }
            }
            .environmentObject(soundManager)
            .environmentObject(healthInteracter)
            .environmentObject(profileModel)
            .onReceive(
                NotificationCenter
                    .default
                    .publisher(
                        for: UIApplication.didBecomeActiveNotification
                    )
            ) { _ in
                hasHealthAuthorization = healthInteracter.haveHealthAuthorization()
                hasLocationAuthorization = healthInteracter.hasLocationAuthorization()
                Task {
                    if hasHealthAuthorization && hasLocationAuthorization {
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
            .alert("🏆 Level Up! ⚽️🏃‍♂️\n\n사커비트가 유저분들의 의견을 반영하여 사용성을 개선했어요\n\n지금 바로 업데이트하고 즐겨보세요!", isPresented: $showUpdate) {
                Button("나중에") {}
                if let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/\(6470206109)") {
                    Link("업데이트", destination: url)
                }
            }
            .task {
                if await AppStoreUpdateChecker.isNewVersionAvailable() {
                    showUpdate.toggle()
                }
            }
        }
    }
}
