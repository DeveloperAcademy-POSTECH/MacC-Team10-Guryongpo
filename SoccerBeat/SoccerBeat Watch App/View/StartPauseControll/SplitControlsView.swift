//
//  SplitControlsView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

// TODO:  - 쪼개지기 전에 투명도 줬다가 쪼개지면서 애니메이션 주면서 불투명도 1
struct SplitControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State var isClicked: Bool = false
    @State var isMoving: Bool = false
    @State var offset: CGFloat = 12
    @State private var textYOffset = -40.0
    
    var body: some View {
        ZStack {
            HStack {
                // MARK: - 나눠진 후 왼쪽, pause & resume
                VStack {
                    Button {
                        workoutManager.togglePause()
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1)
                                .background( Circle().foregroundColor(.circleBackground))
                            
                            Image(systemName: workoutManager.running ? "pause" : "play.fill")
                                .resizable()
                                .frame(width:16, height: 16)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .buttonStyle(.plain)
                    
                    Text(workoutManager.running ? "일시 정지" : "재개")
                        .font(.stopEnd)
                        .offset(x: 0, y: textYOffset)
                }
                .opacity(isMoving ? 1.0 : 0.0)
                .offset(x: isMoving ? 0: offset * 2.0)
                
                // MARK: - 나눠진 후 오른쪽, End
                VStack {
                    Button {
                        // End Workout
                        workoutManager.endWorkout()
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1)
                                .background( Circle().foregroundColor(.circleBackground))
                            
                            Image(systemName: "stop.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .buttonStyle(.plain)
                    
                    Text("경기 종료")
                        .font(.stopEnd)
                        .offset(x: 0, y: textYOffset)
                }
                .opacity(isMoving ? 1.0 : 0.0)
                .offset(x: isMoving ? 0 : -offset * 2.0)
            }
            .padding(.horizontal)
            
            // MARK: - 시작시 timeout 버튼 화면
                Image(.timeOutButton)
                    .opacity(isClicked ? 0 : 1)
                    .buttonStyle(.borderless)
                    .clipShape(Circle())
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
                withAnimation {
                    isClicked = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                withAnimation {
                    isMoving = true
                }
            }
        }
        .onDisappear {
            withAnimation {
                isClicked = false
                isMoving = false
            }
        }
    }
}

#Preview {
    SplitControlsView()
}
