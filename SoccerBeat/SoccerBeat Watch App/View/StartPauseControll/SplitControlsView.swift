//
//  SplitControlsView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

struct SplitControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State var isClicked: Bool = false
    @State var isMoving: Bool = false
    @State var offset: CGFloat = 12
    @State private var textYOffset = -40.0
    
    private var zoneBPMGradient: LinearGradient {
        switch workoutManager.heartZone {
        case 1:
            return .zone1Bpm
        case 2:
            return .zone2Bpm
        case 3:
            return .zone3Bpm
        case 4:
            return .zone4Bpm
        case 5:
            return .zone5Bpm
        default:
            return .zone1Bpm
        }
    }
    
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
                                .foregroundStyle(zoneBPMGradient)
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
                        workoutManager.showingPrecount = false
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1)
                                .background( Circle().foregroundColor(.circleBackground))
                            
                            Image(systemName: "stop.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(zoneBPMGradient)
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
            Image(.stopButton)
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
