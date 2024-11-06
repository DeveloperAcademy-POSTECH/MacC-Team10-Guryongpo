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
    @State private var isShowingHealthAlert = false
    @State private var isShowingLocationAlert = false

    var body: some View {
        VStack {
            if workoutManager.showingSummaryView {
                SummaryView()
            } else if workoutManager.showingPrecount {
                PrecountView()
            } else {
                ZStack {
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
                    }.alert(isPresented: $isShowingHealthAlert) {
                        Alert(title: Text("need_health_authorization"),
                              message: Text("inform_need_health"),
                              dismissButton: .default(Text("close")))
                    }

                    Button(action: handleButtonPress) {
                        Image(.startButton)
                    }
                    .alert(isPresented: $isShowingLocationAlert) {
                        Alert(title: Text("need_location_authorization"),
                              message: Text("inform_need_location"),
                              dismissButton: .default(Text("close")))
                    }
                }

            }
        }
        .buttonStyle(.borderless)
    }

    private func handleButtonPress() {
        checkLocationAuthorization()
        checkHealthAuthorization()
        handleWorkoutStart()
    }

    private func checkLocationAuthorization() {
        workoutManager.checkLocationAuthorization()
        if !workoutManager.hasLocationAuthorization {
            isShowingLocationAlert.toggle()
        }
    }

    private func checkHealthAuthorization() {
        if !workoutManager.hasHealthAuthorization {
            isShowingHealthAlert.toggle()
        }
    }

    private func handleWorkoutStart() {
        let hasAllAuthorization = workoutManager.hasHealthAuthorization
        && workoutManager.hasLocationAuthorization

        if hasAllAuthorization && workoutManager.isHealthDataAvailable {
            workoutManager.showingPrecount.toggle()
        }
    }
}

#Preview {
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()

    return StartView()
        .environmentObject(workoutManager)
}
