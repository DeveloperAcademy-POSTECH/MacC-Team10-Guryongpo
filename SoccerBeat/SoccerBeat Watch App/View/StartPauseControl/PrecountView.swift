//
//  PrecountView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct PrecountView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var count: Int = 3
    @State var showingSession = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - 큰 숫자 이미지 ex: 3, 2, 1
                Image("Precount-"+"\(count)")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                // MARK: - 숫자 이미지 밑에 "..." 신호 대기 점
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                        .opacity(count > 1 ? 0.8 : 0)
                    
                    Circle()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(.precountGradient)
                    
                        .opacity(count > 2 ? 0.6 : 0)
                    
                }
                
            }.onAppear {
                // MARK: - 카운트값과 세션 보여주는 여부 초기화
                // TODO: - onAppear 되면 뷰가 새로 그려져서 항상 count 의 값은 3일 텐데 이 구문이 왜 있는지 궁금합니다.
                showingSession = false
                count = 3
                
                // MARK: - 시간 경과에 따라서 숫자 변화 애니메이션
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    count -= 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    count -= 1
                }
                // MARK: - 세션 화면으로 전환 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    showingSession = true
                }
            }
            .navigationDestination(isPresented: $showingSession) {
                // MARK: - 세션 화면으로 전환 2 
                SessionPagingView()
                    .navigationBarBackButtonHidden()
            }
            .onChange(of: count) { newCount in
                // MARK: - Session Start
                if newCount < 2 {
                    workoutManager.startWorkout()
                }
            }
        }
    }
}

#Preview {
    PrecountView()
}
