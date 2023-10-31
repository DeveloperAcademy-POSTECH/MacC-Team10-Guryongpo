//
//  PrecountView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct PrecountView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var count: Int = 1
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
                        .opacity(0.6)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                        .opacity(count > 1 ? 0.8 : 0)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                        .opacity(count > 2 ? 1 : 0)
                    
                }.padding()
                
            }.onAppear {
                count = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    count += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    count += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showingSession = true
                }
            }
            .navigationDestination(isPresented: $showingSession) {
                // to Session Page
                SessionPagingView()
                    .navigationBarBackButtonHidden()
            }.onDisappear {
                workoutManager.showingPrecount = false
            }
        }
    }
}

#Preview {
    PrecountView()
}
