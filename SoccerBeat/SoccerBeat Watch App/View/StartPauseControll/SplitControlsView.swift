//
//  SplitControlsView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

// TODO:  - 쪼개지기 전에 투명도 줬다가 쪼개지면서 애니메이션 주면서 불투명도 1
struct SplitControlsView: View {
    @State var isClicked: Bool = false
    @State var isMoving: Bool = false
    @State var offset: CGFloat = 15
    @State private var isRunning = false
    @State private var textYOffset = -40.0
    
    var body: some View {
        ZStack {
            HStack {
                // MARK: - 나눠진 후 왼쪽, pause & resume
                VStack {
                    Button {
                        // pause & resume
                        isRunning.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1)
                                .background( Circle().foregroundColor(.circleBackground))
                            
                            Image(systemName: isRunning ? "pause" : "play.fill")
                                .resizable()
                                .frame(width:16, height: 16)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .buttonStyle(.plain)

                    Text(isRunning ? "일시 정지" : "재개")
                        .offset(x: 0, y: textYOffset)
                }
                .offset(x: isMoving ? -offset: offset)
                
                // MARK: - 나눠진 후 오른쪽, End
                VStack {
                    Button {
                        // End Workout
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
                        .offset(x: 0, y: textYOffset)
                }
                .offset(x: isMoving ? offset : -offset)
            }
            .padding(.horizontal)
            
            // MARK: - 시작시 timeout 버튼 화면
            if !isClicked {
                Image(.timeOutButton)
                    .resizable()
                    .scaledToFill()
                    .opacity(isClicked ? 0 : 1)
                    .onTapGesture {
                        withAnimation {
                            isClicked.toggle()
                        }
                    }
            }
        }.onChange(of: isClicked) { _ in
            // 클릭되면 버튼 쪼개지는 애니메이션 수행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                withAnimation {
                    isMoving.toggle()
                }
            }
        }
    }
}

#Preview {
    SplitControlsView()
}
