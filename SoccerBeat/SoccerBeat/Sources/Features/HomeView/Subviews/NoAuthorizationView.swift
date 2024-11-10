//
//  NoAuthorizationView.swift
//  SoccerBeat
//
//  Created by jose Yun on 4/8/24.
//

import SwiftUI

enum Auth {
    case health
    case location
}

struct NoAuthorizationView: View {
    let requestingAuth: Auth
    @State var isNavigated = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Image(.backgroundPattern)
                    .frame(maxHeight: UIScreen.screenHeight)
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                InformationButton(message: "사커비트를 사용하기 위해 권한을 설정해주세요.")
                                
                                Spacer()
                            }
                            .padding(.top, 48)
                            .padding(.bottom, 30)
                            HStack {
                                VStack(alignment: .leading, spacing: 0.0) {
                                    HStack {
                                        Text("접근 권한 안내")
                                            .font(.mainTitleText)
                                            .foregroundStyle(.shareViewSubTitleTint)
                                        Spacer()
                                    }
                                    
                                }
                                .font(.custom("SFProDisplay-HeavyItalic", size: 36))
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 110)
                    
                    ZStack {
                        LightRectangleView()
                            .frame(width: 358, height: 264)
                            .foregroundStyle(.white.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .frame(width: 356, height: 262)
                                    .foregroundStyle(.white.opacity(0.15))
                            }
                        
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 23))
                                VStack(alignment: .leading) {
                                    Text("위치 (필수)")
                                        .font(.noAuthorizationTitleFont)
                                        .foregroundStyle(.brightmint)
                                    Text("스프린트 및 경기장 위치 조회에 사용")
                                        .font(.noAuthorizationExplainFont)
                                }
                                .padding(.leading)
                            }
                            .padding(.horizontal)
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 23))
                                VStack(alignment: .leading) {
                                    Text("건강 (필수)")
                                        .font(.noAuthorizationTitleFont)
                                        .foregroundStyle(.brightmint)
                                    Text("뛴거리 및 속도 측정에 사용")
                                        .font(.noAuthorizationExplainFont)
                                }
                                .padding(.leading)
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                Button {
                                    isNavigated.toggle()
                                } label: {
                                    ZStack {
                                        Capsule(style: .continuous)
                                            .stroke()
                                            .foregroundStyle(.brightmint)
                                            .frame(width: 74, height: 25)
                                        Capsule(style: .continuous)
                                            .foregroundStyle(Color(hex: 0x03FFC3, alpha: 0.8))
                                            .frame(width: 74, height: 25)
                                        Text("확인")
                                            .foregroundStyle(.white)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(40)
                        
                        Spacer()
                    }
                    .navigationDestination(isPresented: $isNavigated) {
                        GuideAuthorizationView(requestingAuth: requestingAuth)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    NoAuthorizationView(requestingAuth: .health)
}
