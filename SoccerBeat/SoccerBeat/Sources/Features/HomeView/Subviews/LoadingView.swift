//
//  LoadingView.swift
//  SoccerBeat
//
//  Created by Gucci on 4/13/24.
//

import SkeletonUI
import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ProgressView()
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager.shared

    return LoadingView()
        .environmentObject(workoutManager)
}
