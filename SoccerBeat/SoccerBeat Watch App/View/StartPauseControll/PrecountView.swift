//
//  PrecountView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct PrecountView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var count: Int = 3
    @State var showingSession = false
    var body: some View {
        NavigationStack {
            VStack {
                Image("Precount-"+"\(count)")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
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
                
            }.onAppear {
                showingSession = false
                count = 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    count -= 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    count -= 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    showingSession = true
                }
            }
            .navigationDestination(isPresented: $showingSession) {
                // to Session Page
                SessionPagingView()
                    .navigationBarBackButtonHidden()
            }
            .onChange(of: count) { newCount in
                // MARK: - Session Start
                if newCount < 2 {
                    workoutManager.startWorkout()
                }
            }
        }
    }
}

#Preview {
    PrecountView()
}
