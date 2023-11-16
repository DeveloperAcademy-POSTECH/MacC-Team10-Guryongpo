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
                        
                        NavigationLink {
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        let average = [3.0, 2.4, 3.4, 3.2, 2.8, 3.3]
                                        let recent = [4.1, 3.0, 3.5, 3.8, 3.5, 2.8]
                                        ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
                                            .scaleEffect(CGSize(width: 0.7, height: 0.7))
                                            .fixedSize()
                                            .frame(width: 210, height: 210)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .overlay {
                                LightRectangleView()
                            }.padding(.horizontal)
                        }
                        
                        NavigationLink {
                            MatchRecapView(userWorkouts: $userWorkouts)
                        } label: {
                            HStack {
                                Spacer()
                                
                                Image(systemName: "soccerball")
                                Text("이전 경기")
                                
                                Spacer()
                            }
                            .padding()
                            .overlay {
                                LightRectangleView()
                            }.padding(.horizontal)
                        }
                        
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
