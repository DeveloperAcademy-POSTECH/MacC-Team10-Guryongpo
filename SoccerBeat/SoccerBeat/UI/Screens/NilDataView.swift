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
                    .padding(.top, 5)
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
                            
                            Text("앱 사용을 위해 헬스 정보 접근 권한이 필요합니다.")
                                .font(.custom("NotoSans-Regular", size: 14))
                            HStack {
                                Button("위치 권한 설정하기") {
                                    openSettings(urlString: UIApplication.openSettingsURLString)
                                }
                                .buttonStyle(BorderedButtonStyle())
                                
                                Button("건강 권한 설정하기") {
                                    let healthSettingURLString =  "x-apple-health://"
                                    openSettings(urlString: healthSettingURLString)
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }                            
                        }
                    }
                
                Spacer()
                    .frame(height: 60)
                
                VStack(alignment: .leading) {
                    InformationButton(message: "최근 경기 데이터의 변화를 확인해 보세요.")
                    
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
        .padding(.horizontal)
        .navigationTitle("")
    }
    
    private func openSettings(urlString: String) {
        guard let url = URL(string: urlString) else {
            NSLog("잘못된 URL입니다.: \(#function), URL: \(urlString)")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
