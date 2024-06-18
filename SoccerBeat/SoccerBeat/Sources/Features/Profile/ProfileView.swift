//
//  ProfileView.swift
//  SoccerBeat
//
//  Created by daaan on 11/17/23.
//

// 추후 로직 변경 필요

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @State private var isFlipped = false
    @State private var userImage: UIImage?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                InformationButton(message: "나의 선수 카드와 최대 능력치를 만나보세요.")
                                Spacer()
                            }
                            .padding(.bottom, 30)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    VStack {
                                        Spacer()
                                        
                                        MyCardView(isFlipped: $isFlipped)
                                            .frame(width: 95)
                                        
                                        PhotoSelectButtonView()
                                            .opacity(isFlipped ? 1 : 0)
                                            .padding(.top, 10)
                                    }
                                    
                                    Spacer()
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: nil) {
                                        
                                        Text("SBeat Card")
                                            .font(.matchDetailSubTitle)
                                            .foregroundStyle(.shareViewSubTitleTint)
                                            .offset(y: -10)
                                        HStack(spacing: nil) {
                                            Text("How ")
                                            Text("you")
                                                .bold()
                                                .foregroundStyle(.brightmint)
                                        }
                                        HStack(spacing: nil) {
                                            Text("like")
                                            Text("that?")
                                                .foregroundStyle(.brightmint)
                                                .highlighter(activity: .heartrate, isDefault: true)
                                        }
                                        .offset(y: -8)
                                    }
                                    Spacer()
                                }
                                NameFieldView()
                            }
                            .font(.mainTitleText)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 110)
                    
                    VStack(spacing: 6) {
                        HStack {
                            HStack(spacing: 0) {
                                Text("")
                                Text("파란색")
                                    .bold()
                                    .foregroundStyle(
                                        .raderMaximumColor)
                                Text("은 시즌 최고 능력치입니다.")
                            }
                            .floatingCapsuleStyle()
                            Spacer()
                        }
                        
                        HStack {
                            HStack(spacing: 0) {
                                Text("")
                                Text("민트색")
                                    .bold()
                                    .foregroundStyle(.matchDetailViewAverageStatColor)
                                Text("은 경기 평균 능력치입니다.")
                            }
                            .floatingCapsuleStyle()
                            Spacer()
                        }
                    }
                    
                    let average = DataConverter.toLevels(profileModel.averageAbility)
                    let maximumAbility = DataConverter.toLevels(profileModel.maxAbility)
                    
                    ViewControllerContainer(ProfileViewController(radarAverageValue: average, radarAtypicalValue: maximumAbility))
                                            .fixedSize()
                                            .frame(width: 304, height: 348)
                                            .zIndex(-1)
                    
                    Spacer()
                        .frame(height: 110)
                    
                    TrophyCollectionView()
                    
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            
        }
        .toolbar {
            NavigationLink {
                ShareView()
            } label: {
                Text("공유하기")
                    .foregroundStyle(.shareViewTitleTint)
            }
        }
        .navigationTitle("")
        .padding()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
}
