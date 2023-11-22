//
//  ProfileView.swift
//  SoccerBeat
//
//  Created by daaan on 11/17/23.
//

import SwiftUI

struct ProfileView: View {
    @State var isFlipped: Bool = false
    @State var userName: String = ""
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    @State var userImage: UIImage?
    @FocusState private var isFocused: Bool
    @ObservedObject var viewModel: ProfileModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    BackgroundImageView()
                    
                    VStack {
                        
                        HStack {
                            VStack {
                                
                                HStack {
                                    Text(" 나만의 선수 카드를 만들어 보세요.")
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
                                                            .foregroundColor(userName.count >= 6 ? .red : .brightmint)
                                                    }
                                            }
                                                
                                            TextField("Name", text: $userName)
                                                .limitText($userName, to: 5)
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
                                        Text("")
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
                                        Text("")
                                        Text("민트색")
                                            .bold()
                                            .foregroundStyle(.matchDetailViewAverageStatColor)
                                        Text("은 경기 평균 능력치입니다.")
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
                        
                        let averageLevel = dataConverter(totalDistance: averageData.totalDistance,
                                                   maxHeartRate: averageData.maxHeartRate,
                                                   maxVelocity: averageData.maxVelocity,
                                                   maxAcceleration: averageData.maxAcceleration,
                                                   sprintCount: averageData.sprintCount,
                                                   minHeartRate: averageData.minHeartRate,
                                                   rangeHeartRate: averageData.rangeHeartRate,
                                                   totalMatchTime: averageData.totalMatchTime)
                        let average = [(averageLevel["totalDistance"] ?? 1.0) * 0.15 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.35,
                                       (averageLevel["maxVelocity"] ?? 1.0) * 0.3 + (averageLevel["maxAcceleration"] ?? 1.0) * 0.2,
                                       (averageLevel["maxVelocity"] ?? 1.0) * 0.25 + (averageLevel["sprintCount"] ?? 1.0) * 0.125 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.125,
                                       (averageLevel["maxAcceleration"] ?? 1.0) * 0.4 + (averageLevel["minHeartRate"] ?? 1.0) * 0.1,
                                       (averageLevel["totalDistance"] ?? 1.0) * 0.15 + (averageLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (averageLevel["totalMatchTime"] ?? 1.0) * 0.2,
                                       (averageLevel["totalDistance"] ?? 1.0) * 0.3 + (averageLevel["sprintCount"] ?? 1.0) * 0.1 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.1]
                        
                        let maximumLevel = dataConverter(totalDistance: maximumData.totalDistance,
                                                        maxHeartRate: maximumData.maxHeartRate,
                                                        maxVelocity: maximumData.maxVelocity,
                                                        maxAcceleration: maximumData.maxAcceleration,
                                                        sprintCount: maximumData.sprintCount,
                                                        minHeartRate: maximumData.minHeartRate,
                                                        rangeHeartRate: maximumData.rangeHeartRate,
                                                         totalMatchTime: maximumData.totalMatchTime)
                        let recent = [(maximumLevel["totalDistance"] ?? 1.0) * 0.15 + (maximumLevel["maxHeartRate"] ?? 1.0) * 0.35,
                                       (maximumLevel["maxVelocity"] ?? 1.0) * 0.3 + (maximumLevel["maxAcceleration"] ?? 1.0) * 0.2,
                                       (maximumLevel["maxVelocity"] ?? 1.0) * 0.25 + (maximumLevel["sprintCount"] ?? 1.0) * 0.125 + (maximumLevel["maxHeartRate"] ?? 1.0) * 0.125,
                                       (maximumLevel["maxAcceleration"] ?? 1.0) * 0.4 + (maximumLevel["minHeartRate"] ?? 1.0) * 0.1,
                                       (maximumLevel["totalDistance"] ?? 1.0) * 0.15 + (maximumLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (maximumLevel["totalMatchTime"] ?? 1.0) * 0.2,
                                       (maximumLevel["totalDistance"] ?? 1.0) * 0.3 + (maximumLevel["sprintCount"] ?? 1.0) * 0.1 + (maximumLevel["maxHeartRate"] ?? 1.0) * 0.1]
                        
                        
                        ViewControllerContainer(ProfileViewController(radarAverageValue: average, radarAtypicalValue: recent))
                            .fixedSize()
                            .frame(width: 304, height: 348)
                            .zIndex(-1)
                        
                        TrophyCollectionView()
                        
                    }
                }.onTapGesture {
                    hideKeyboard()
                }
            }
            .onAppear {
                userName = UserDefaults.standard.string(forKey: "userName") ?? ""
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//#Preview {
//    ProfileView()
//}
