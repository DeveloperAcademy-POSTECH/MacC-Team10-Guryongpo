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
            SplitControlsView()
                .tag(TabSort.controls)
            
                GameProgressView()
                    .tag(TabSort.progress)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .progress)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayMetricsView()
        }
        .onChange(of: workoutManager.running) { _ in
            // MARK: When session is not started, the view will be automatically switched to Metrics
            displayMetricsView()

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
