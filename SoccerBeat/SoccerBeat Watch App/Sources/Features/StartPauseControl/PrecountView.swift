//
//  PrecountView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct PrecountView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var count = 3
    @State private var showingSession = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - 큰 숫자 이미지 ex: 3, 2, 1
                Image("Precount-"+"\(count)")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                // MARK: - 숫자 이미지 밑에 "..." 신호 대기 점
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                        .opacity(count > 1 ? 0.8 : 0)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                    
                        .opacity(count > 2 ? 0.6 : 0)
                    
                }
                
            }
            .task {
                count = 3
                showingSession = false
                do {
                    try await Task.sleep(nanoseconds: 700_000_000)
                    guard workoutManager.showingPrecount, !workoutManager.showingSummaryView else { return }
                    count = 2
                    try await Task.sleep(nanoseconds: 700_000_000)
                    guard workoutManager.showingPrecount, !workoutManager.showingSummaryView else { return }
                    count = 1
                    workoutManager.startWorkout()
                    try await Task.sleep(nanoseconds: 700_000_000)
                    guard workoutManager.showingPrecount, !workoutManager.showingSummaryView else { return }
                    showingSession = true
                } catch {
                    // Leaving the countdown cancels Task.sleep and its pending session start.
                }
            }
            // TODO: - 이 네비게이션이 PrecountView가 아니라 다른 곳에 있어야 하지 않을까?
            .navigationDestination(isPresented: $showingSession) {
                // MARK: - 세션 화면으로 전환 2 
                SessionPagingView()
                    .navigationBarBackButtonHidden()
            }

        }
    }
}

#Preview {
    PrecountView()
}
