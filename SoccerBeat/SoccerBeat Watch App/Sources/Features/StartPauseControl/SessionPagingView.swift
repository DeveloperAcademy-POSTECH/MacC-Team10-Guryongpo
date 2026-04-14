//
//  SessionPagingView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI
import WatchKit

//  MARK: - 세션의 페이징을 하는 뷰, 좌우의 페이징을 담당
struct SessionPagingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: TabSort = .progress
    
    private enum TabSort {
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
        .tabViewStyle(.page)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
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
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()
    
    return SessionPagingView()
        .environmentObject(workoutManager)
}
