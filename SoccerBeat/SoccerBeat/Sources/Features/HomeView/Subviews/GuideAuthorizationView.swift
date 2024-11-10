//
//  GuideAuthorizationView.swift
//  SoccerBeat
//
//  Created by jose Yun on 3/22/24.
//

import SwiftUI

struct GuideAuthorizationView: View {
    let requestingAuth: Auth
    @State var isShowingQuestion = false
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image(.backgroundPattern)
                    .frame(maxHeight: UIScreen.screenHeight)
                    .opacity(0.5)
                VStack {
                    VStack {
                        HStack {
                            if requestingAuth == .health {
                                InformationButton(message: "사커비트의 건강 권한이 없습니다.")
                            } else {
                                InformationButton(message: "사커비트의 위치 권한이 없습니다.")
                            }
                            Spacer()
                        }
                        .padding(.top, 48)
                        .padding(.bottom, 30)
                        HStack {
                            VStack(alignment: .leading, spacing: 0.0) {
                                HStack {
                                    if requestingAuth == .health {
                                        Text("건강 권한 설정하기")
                                            .font(.matchDetailSubTitle)
                                            .foregroundStyle(.shareViewSubTitleTint)
                                    } else {
                                        Text("위치 권한 설정하기")
                                            .font(.matchDetailSubTitle)
                                            .foregroundStyle(.shareViewSubTitleTint)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .font(.custom("SFProDisplay-HeavyItalic", size: 36))
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                        .frame(height: 110)
                    
                    ZStack {
                        LightRectangleView()
                            .frame(width: 358, height: 264)
                            .foregroundStyle(.white.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .frame(width: 356, height: 264)
                                    .foregroundStyle(.white.opacity(0.15))
                            }
                        
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button(action: { isShowingQuestion.toggle() } ) {
                                    Image(systemName: "questionmark")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 14))
                                        .padding()
                                }
                                .overlay {
                                    Capsule()
                                        .stroke(lineWidth: 0.8)
                                        .frame(height: 22)
                                }
                                .padding(.horizontal)
                            }.offset(y: -20)
                            
                            VStack(alignment: .leading) {
                                if requestingAuth == .health {
                                    Text("> 개인 정보 보호 및 보안\n> 건강\n> SoccerBeat > 모두켜기\n 순서로 설정해주세요.")
                                        .font(.noAuthorizationTitleFont)
                                        .foregroundStyle(.brightmint)
                                } else {
                                    Text("> 개인 정보 보호 및 보안\n> 위치 서비스\n> SoccerBeat > 모두켜기\n 순서로 설정해주세요.")
                                        .font(.noAuthorizationTitleFont)
                                        .foregroundStyle(.brightmint)
                                }
                            }.offset(y: -10)
                            
                            Spacer()
                                .frame(height: 24)
                            
                            HStack {
                                Spacer()
                                Button {
                                    if let bundleIdentifier = Bundle.main.bundleIdentifier,
                                       let url = requestingAuth == .health ? URL(string: "App-Prefs:HEALTH&path=SOURCES")! : URL(string: "\(UIApplication.openSettingsURLString)\(bundleIdentifier)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                } label: {
                                    ZStack {
                                        Capsule(style: .continuous)
                                            .stroke()
                                            .foregroundStyle(.brightmint)
                                            .frame(width: 102, height: 25)
                                        Capsule(style: .continuous)
                                            .foregroundStyle(Color(hex: 0x03FFC3, alpha: 0.8))
                                            .frame(width: 102, height: 25)
                                        Text("설정하기")
                                            .foregroundStyle(.white)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(40)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $isShowingQuestion) {
                DetailGuideView(requestingAuth: requestingAuth, isShowingQuestion: $isShowingQuestion)
                    .presentationDetents([.height(600)])
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GuideAuthorizationView(requestingAuth: .health)
}
