//
//  ProfileView.swift
//  SoccerBeat
//
//  Created by daaan on 11/17/23.
//

import SwiftUI

struct ProfileView: View {
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    @State var userName: String = ""
    @Binding var averageData: WorkoutAverageData
    @State var userImage: UIImage?
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    BackgroundImageView()
                    
                    VStack {
                        
                        HStack {
                            VStack {
                                
                                HStack {
                                    Text("# 나만의 선수 카드를 만들어 보세요.")
                                        .floatingCapsuleStyle()
                                    Spacer()
                                }
                                .padding(.top, 60)
                                .padding(.leading)
                                .padding(.bottom, 30)
                                
                                VStack(alignment: .leading, spacing: 0.0) {
                                    HStack {
                                        Text("선수 프로필")
                                            .font(.matchDetailSubTitle)
                                            .foregroundStyle(.shareViewSubTitleTint)
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        ZStack(alignment: .leading) {
                                            if !userName.isEmpty {
                                                Text(userName)
                                                    .padding(.horizontal)
                                                    .overlay {
                                                        Capsule()
                                                            .stroke(style: .init(lineWidth: 0.8))
                                                            .frame(height: 40)
                                                            .foregroundColor(userName.count >= 7 ? .red : .brightmint)
                                                    }
                                            }
                                                
                                            TextField("Name", text: $userName)
                                                .limitText($userName, to: 6)
                                                .padding(.horizontal)
                                                .onChange(of: userName) { _ in
                                                    UserDefaults.standard.set(userName, forKey: "userName")
                                                }
                                        }
                                            
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("How you")
                                            Text("like that")
                                        }.kerning(-0.4)
                                        
                                    }
                                }
                                .font(.custom("SFProDisplay-HeavyItalic", size: 36))
                                .padding(.leading)
                                .padding(.leading)
                                
                                
                                HStack {
                                    HStack(spacing: 0) {
                                        Text("#")
                                        Text("파란색")
                                            .bold()
                                            .foregroundStyle(
                                                .raderMaximumColor)
                                        Text("은 시즌 최고 능력치입니다.")
                                    }.floatingCapsuleStyle()
                                        .padding(.leading)
                                    Spacer()
                                }
                                
                                HStack {
                                    HStack(spacing: 0) {
                                        Text("#")
                                        Text("민트색")
                                            .bold()
                                            .foregroundStyle(.matchDetailViewAverageStatColor)
                                        Text("은 평균 능력치입니다.")
                                    }.floatingCapsuleStyle()                    .padding(.leading)
                                    Spacer()
                                }
                            }
                            
                            VStack {
                                MyCardView(isFlipped: $isFlipped, viewModel: viewModel)
                                    .frame(width: 112)
                                    .padding()
                                PhotoSelectButtonView(viewModel: viewModel)
                                    .opacity(isFlipped ? 1 : 0)
                            }
                            
                        }
                        
                        
                        Spacer()
                        
                        let levels = dataConverter(totalDistance: averageData.totalDistance,
                                                   maxHeartRate: averageData.maxHeartRate,
                                                   maxVelocity: averageData.maxVelocity,
                                                   maxAcceleration: averageData.maxAcceleration,
                                                   sprintCount: averageData.sprintCount,
                                                   minHeartRate: averageData.minHeartRate,
                                                   rangeHeartRate: averageData.rangeHeartRate,
                                                   totalMatchTime: averageData.totalMatchTime)
                        let average = [(levels["totalDistance"] ?? 1.0) * 0.15 + (levels["maxHeartRate"] ?? 1.0) * 0.35,
                                       (levels["maxVelocity"] ?? 1.0) * 0.3 + (levels["maxAcceleration"] ?? 1.0) * 0.2,
                                       (levels["maxVelocity"] ?? 1.0) * 0.25 + (levels["sprintCount"] ?? 1.0) * 0.125 + (levels["maxHeartRate"] ?? 1.0) * 0.125,
                                       (levels["maxAcceleration"] ?? 1.0) * 0.4 + (levels["minHeartRate"] ?? 1.0) * 0.1,
                                       (levels["totalDistance"] ?? 1.0) * 0.15 + (levels["rangeHeartRate"] ?? 1.0) * 0.15 + (levels["totalMatchTime"] ?? 1.0) * 0.2,
                                       (levels["totalDistance"] ?? 1.0) * 0.3 + (levels["sprintCount"] ?? 1.0) * 0.1 + (levels["maxHeartRate"] ?? 1.0) * 0.1]
                        let recent = [4.1, 3.0, 3.5, 3.8, 3.5, 2.8]
                        
                        
//                        ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
//                            .fixedSize()
//                            .frame(width: 304, height: 348)
//                        
                        TrophyCollectionView()
                        
                    }
                }
            }
            .onAppear {
                userName = UserDefaults.standard.string(forKey: "userName") ?? ""
            }
        }
    }
}

//#Preview {
//    ProfileView()
//}
