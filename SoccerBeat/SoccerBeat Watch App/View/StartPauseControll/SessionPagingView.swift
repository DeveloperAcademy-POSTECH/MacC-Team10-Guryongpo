//
//  SessionPagingView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Environment(\.dismiss) var dismiss
    @State private var selection: TabSort = .progress

    enum TabSort {
        case controls, progress
    }

    var body: some View {
        TabView(selection: $selection) {
            SplitControlsView().tag(TabSort.controls)
            GameProgressView().tag(TabSort.progress)
        }
        .environmentObject(workoutManager)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .progress)
        .onChange(of: workoutManager.running) { isRunning in
            displayMetricsView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayMetricsView()
        }
        .onAppear {
            // MARK: - Session Start
            workoutManager.startWorkout()
        }
    }

    private func displayMetricsView() {
        withAnimation {
            selection = .progress
        }
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()
    
    return SessionPagingView()
        .environmentObject(workoutManager)
}
