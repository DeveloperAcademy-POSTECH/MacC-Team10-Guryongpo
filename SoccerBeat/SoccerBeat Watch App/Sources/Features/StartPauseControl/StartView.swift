//
//  StartView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack {
            if workoutManager.showingSummaryView {
                SummaryView()
            } else if workoutManager.showingPrecount {
                PrecountView()
            } else if workoutManager.hasAllAuthorization {
                startButtonView
            } else {
                PermissionRequiredView()
            }
        }
        .buttonStyle(.borderless)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                workoutManager.checkLocationAuthorization()
                workoutManager.objectWillChange.send()
            }
        }
    }

    private var startButtonView: some View {
        ZStack {
            if let url = Bundle.main.path(forResource: "StartGlow", ofType: "gif") {
                WebImage(url: URL(fileURLWithPath: url))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(0.9)
                    .playbackMode(.normal)
                    .scaledToFill()
                    .frame(width: 250)
                    .background(Color.clear)
                    .opacity(0.3)
            }

            Button(action: {
                workoutManager.showingPrecount.toggle()
            }) {
                Image(.startButton)
            }
        }
    }
}

#Preview {
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()

    return StartView()
        .environmentObject(workoutManager)
}
