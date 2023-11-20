//
//  NilDataView.swift
//  SoccerBeat
//
//  Created by daaan on 11/20/23.
//

import SwiftUI

struct NilDataView: View {
    var body: some View {
        ZStack {
            BackgroundImageView()
            
            VStack(spacing: 0.0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("# 가장 최근에 기록한 경기를 만나보세요")
                            .floatingCapsuleStyle()
                            .padding(.bottom)
                        
                        Text("최근 경기")
                            .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                        Text("2023/11/23")
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title)
                    }
                }.padding(.horizontal)
                
                LightRectangleView(alpha: 0.6, color: .black, radius: 15.0)
                    .frame(height: 234)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay {
                        VStack {
                            Text("저장된 경기 기록이 없습니다.")
                                .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .font(.custom("SFProText-HeavyItalic", size: 24))
                            
                            Text("앱 사용을 위해 헬스 정보 접근 권한이 필요합니다.")
                                .font(.custom("NotoSans-Regular", size: 14))
                            
                            Text("승인하지 않으셨다면 설정 앱에서 권한을 승인해주세요.")
                                .font(.custom("NotoSans-Regular", size: 14))
                        }
                    }
                
                Spacer()
                    .frame(height: 60)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("# 경기 퍼포먼스의 변화 추세를 살펴보세요")
                            .floatingCapsuleStyle()
                            .padding(.bottom)
                        
                        Text("추세")
                            .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                    }
                    Spacer()
                }.padding(.horizontal)
                
                LightRectangleView(alpha: 0.6, color: .black, radius: 15.0)
                    .frame(height: 90)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay {
                        Text("저장된 경기 기록이 없습니다.")
                            .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .font(.custom("SFProText-HeavyItalic", size: 24))
                    }
                
                Spacer()
            }.padding(.top, 10.0)
        }
    }
}

#Preview {
    NilDataView()
}
