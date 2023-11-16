//
//  MainView.swift
//  SoccerBeat
//
//  Created by daaan on 11/16/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    @Binding var userWorkouts: [WorkoutData]?
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    BackgroundImageView()
                    
                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("# 경기를 시작해 볼까요?")
                                    .floatingCapsuleStyle()
                                
                                Text("최근 경기")
                                    .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                                Text("2023/11/23")
                                    .opacity(0.7)
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                            } label: {
                                Image(systemName: "person.circle")
                                    .font(.title)
                            }
                        }.padding()
                        AnalyticsView()
                            .environmentObject(healthInteractor)
                        Spacer()
                            .frame(height: 60)
                        
                    }
                }
            }
            .navigationTitle("")
        }
    }
}

#Preview {
    MainView(userWorkouts: .constant(fakeWorkoutData))
}
