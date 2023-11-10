//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @ObservedObject var healthInteractor = HealthInteractor.shared
    @EnvironmentObject var soundManager: SoundManager
    @State var userWorkouts: [WorkoutData]?
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    Image("BackgroundPattern")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 0)
                    
                    VStack {
                        
                        MyCardView(isFlipped: $isFlipped, viewModel: viewModel)
                        PhotoSelectButtonView(viewModel: viewModel)
                            .opacity(isFlipped ? 1 : 0)
                            .padding()
                        
                        Spacer()
                            .frame(height: 114) 
                        
                        MatchRecapView(userWorkouts: $userWorkouts)
                        
                        Spacer()
                            .frame(height: 60)
                        
                        AnalyticsView(userWorkouts: $userWorkouts)
                        
                        Spacer()
                            .frame(height: 60)
                        
                    }
                }
            }
            .navigationTitle("")
        }
        .task {
            healthInteractor.requestAuthorization()
        }
        .onReceive(healthInteractor.authSuccess, perform: {
            Task {
                print("ContentView: attempting to fetch all data..")
                await healthInteractor.fetchAllData()
            }
        })
        .onReceive(healthInteractor.fetchSuccess, perform: {
            print("ContentView: fetching user data success..")
            self.userWorkouts = healthInteractor.userWorkouts
        })
        .tint(.white)
        .onAppear {
            // 시끄러우면 각주 처리해주세요 -호제가-
            soundManager.playBackground()
        }

    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
