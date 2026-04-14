//
//  SplitControlsView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI
import SDWebImageSwiftUI

// TODO: - 전체적으로 오프셋으로 조정하는 방식인데 이는 화면 크기가 달라질 때마다 차이가 있을 수 있으니 padding 값을 기반으로 해서 변화하는 것을 도입 고려
struct SplitControlsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var matrics: MatricsIndicator
    @State private var isClicked = false
    @State private var isMoving = false
    @State private var offset = 12.0 // TODO: - 어떤 오프셋인지 설명 필요 1
    @State private var textYOffset = -40.0  // TODO: - 어떤 오프셋인지 설명 필요 2
    
    var body: some View {
        ZStack {
            if let url = Bundle.main.path(forResource: "StartGlow", ofType: "gif") {
                WebImage(url: URL(fileURLWithPath: url))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(0.9)
                    .playbackMode(.normal)
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.5)
                    .opacity(0.3)
            }
            HStack {
                // MARK: - 나눠진 후 왼쪽, pause & resume
                VStack {
                    sessionControlButton(type: .resumeAndStop)
                    
                    Text(workoutManager.running ? "일시 정지" : "재개")
                        .font(.stopEnd)
                        .offset(x: 0, y: textYOffset)
                }
                .opacity(isMoving ? 1.0 : 0.0)
                .offset(x: isMoving ? 0: offset * 2.0)
                
                // MARK: - 나눠진 후 오른쪽, End
                VStack {
                    sessionControlButton(type: .end)
                    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
                withAnimation {
                    isClicked = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 ) {
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

private extension SplitControlsView {
    enum SessionControl {
        case resumeAndStop
        case end
    }
    
    private var zoneBPMGradient: LinearGradient {
        switch matrics.heartZone {
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
    
    @ViewBuilder
    func sessionControlButton(type sessionControl: SessionControl) -> some View {
        let action = {
            switch sessionControl {
            case .resumeAndStop:
                workoutManager.togglePause()
            case .end:
                workoutManager.endWorkout()
            }
        }
        
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: 1)
                    .background( Circle().foregroundColor(.circleBackground))
                
                switch sessionControl {
                case .resumeAndStop:
                    Image(systemName: workoutManager.running ? "pause" : "play.fill")
                        .sessionControllerModifier(coloring: zoneBPMGradient)
                case .end:
                    Image(systemName: "stop.fill")
                        .sessionControllerModifier(coloring: zoneBPMGradient)
                }
            }
        }
        .padding(16)
        .buttonStyle(.plain)
    }
}

private extension Image {
    func sessionControllerModifier(coloring gradientColor: LinearGradient) -> some View {
        self
            .resizable()
            .frame(width:16, height: 16)
            .foregroundStyle(gradientColor)
    }
}

