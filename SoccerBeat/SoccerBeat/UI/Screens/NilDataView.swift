//
//  NilDataView.swift
//  SoccerBeat
//
//  Created by daaan on 11/20/23.
//

import SwiftUI

struct NilDataView: View {
    @State var workoutAverageData: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0, minHeartRate: 0, rangeHeartRate: 0, totalDistance: 0, maxAcceleration: 0, maxVelocity: 0, sprintCount: 0, totalMatchTime: 0)
    @EnvironmentObject var soundManager: SoundManager
    @ObservedObject var viewModel: ProfileModel
    @Binding var maximumData: WorkoutAverageData
    
    var body: some View {
        ZStack {
            BackgroundImageView()
            
            VStack(spacing: 0.0) {
                
                HStack {
                    Button(action: { soundManager.isPlaying.toggle() },
                           label : {
                        HStack {
                            Image(systemName: soundManager.isPlaying ? "speaker" : "speaker.slash")
                            Text(soundManager.isPlaying ? "On" : "Off")
                        }
                        .padding(.horizontal)
                        .font(.mainInfoText)
                        .overlay {
                            Capsule()
                                .stroke()
                                .frame(width: 77, height: 24)
                        }
                    })
                    .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("----.--.--")
                            .font(.mainSubTitleText)
                            .opacity(0.7)
                        Text("최근 경기")
                            .font(.mainTitleText)
                    }
                    Spacer()
                    NavigationLink {
                        ProfileView(averageData: $workoutAverageData, maximumData: $maximumData, viewModel: viewModel)
                    } label: {
                        CardFront(width: 72, height: 96, degree: .constant(0), viewModel: viewModel)
                    }
                }
                .padding()
                
                
                LightRectangleView(alpha: 0.6, color: .black, radius: 15.0)
                    .frame(height: 234)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        VStack(alignment: .center) {
                            Text("저장된 경기 기록이 없습니다.")
                                .font(.mainSubTitleText)
                                .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding()
                            
                            Group {
                                Text("앱 사용을 위해 헬스 정보 접근 권한이 필요합니다.")
                                Text("승인하지 않으셨다면 설정 앱에서 권한을 승인해주세요.")
                            }
                            .font(.mainInfoText)
                            .opacity(0.7)
                            
                        }
                    }
                
                Spacer()
                    .frame(height: 60)
                
                VStack(alignment: .leading) {
                    Image(systemName: "info.circle")
                        .font(.mainInfoText)
                        .overlay {
                            Capsule()
                                .stroke()
                                .frame(height: 24)
                        }
                    HStack {
                        Text("추세")
                            .font(.mainTitleText)
                        Spacer()
                    }
                    .padding()
                }

                LightRectangleView(alpha: 0.15, color: .black, radius: 15.0)
                    .frame(height: 90)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Text("저장된 경기 기록이 없습니다.")
                            .font(.mainSubTitleText)
                            .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .navigationTitle("")
    }
}
