//
//  EmptyDataView.swift
//  SoccerBeat
//
//  Created by Gucci on 4/15/24.
//

import SwiftUI

struct EmptyDataView: View {
    private let emptyDataMessage = "저장된 경기 기록이 없습니다."
    
    var body: some View {
        ZStack {
            // 배경 이미지
            Image(.backgroundPattern)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: UIScreen.screenHeight)
                .clipped()
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // 최근 경기
                    VStack(alignment: .leading, spacing: 4) {
                        InformationButton(message: "가장 최근에 기록한 경기를 만나보세요")
                        
                        Text("최근 경기")
                            .font(.mainTitleText)
                    }
                    
                    Spacer()
                    
                    // 프로필 이미지 카드 뷰
                    NavigationLink {
                        ProfileView()
                    } label: {
                        CardFront(degree: .constant(0), width: 72, height: 110)
                    }
                }
                .padding(.horizontal, 16)
                    
                // 최근 경기 알림판
                ZStack {
                    LightRectangleView()
                        .frame(height: 234)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.white.opacity(0.1))
                    
                    VStack(spacing: nil) {
                        highlightedInfomationalText(emptyDataMessage)
                            .padding(.top, 46)
                        
                        Text("애플워치를 차고 당신의 첫 번째 경기를 기록해 보세요!")
                            .font(.notoSans(size: 14))
                            .foregroundStyle(.subInfomational)
                            .padding(.top, 20)
                    }
                }
                
                // 추세
                VStack(alignment: .leading, spacing: 4) {
                    InformationButton(message: "경기 퍼포먼스의 변화 추세를 살펴보세요")
                    
                    Text("추세")
                        .font(.mainTitleText)
                }
                .padding(.leading, 16)
                .padding(.top, 40)
                
                // 추세 알림판
                ZStack {
                    LightRectangleView()
                        .frame(height: 91)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.white.opacity(0.1))
                    
                    VStack(spacing: nil) {
                        highlightedInfomationalText(emptyDataMessage)
                    }
                }
                
                Spacer()
                    .frame(height: 170)
            }
        }
    }

    private func highlightedInfomationalText(_ message: String) -> some View {
        Text(emptyDataMessage)
            .font(.summaryContent)
            .foregroundStyle(.playTimeNumber)
    }
}

#Preview {
    @StateObject var profileModel = ProfileModel(healthInteractor: HealthInteractor.shared)
    
    return NavigationStack {
        EmptyDataView()
              .environmentObject(profileModel)
    }
}
