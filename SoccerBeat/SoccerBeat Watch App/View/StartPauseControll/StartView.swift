//
//  StartView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        NavigationStack {
            if !workoutManager.showingPrecount {
                Button(action: { workoutManager.showingPrecount.toggle()
                print(workoutManager.showingPrecount)
                } ) {
                    Image(.startButton)
                }
            } else {
                PrecountView()
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()

    return StartView()
        .environmentObject(workoutManager)
}
