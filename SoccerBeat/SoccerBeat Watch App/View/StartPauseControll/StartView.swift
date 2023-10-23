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
        NavigationLink {
            // to Session Page
            SessionPagingView()
                .navigationBarBackButtonHidden()
                .environmentObject(workoutManager)
        } label: {
            Image(.startButton)
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
        .buttonStyle(.borderless)
        .clipShape(Circle())
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()

    return StartView()
        .environmentObject(workoutManager)
}
