////
////  BPMTextView.swift
////  SoccerBeat Watch App
////
////  Created by Gucci on 10/23/23.
////
//
import SwiftUI

struct BPMTextView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var firstCircle = 1.0
    @State private var secondCircle = 1.0
    let textGradient: LinearGradient
    private var bpm: Int {
        Int(workoutManager.heartRate)
    }
    
    var body: some View {
        ZStack {
            // 기본 텍스트
            Group {
                Text(bpm, format: .number)
                    .font(.system(size: 56).bold().italic())
                + Text(" bpm")
                    .font(.system(size: 28).bold().italic())
            }
            
            // 첫 파문

            HStack {
                Group {
                    Text(bpm, format: .number)
                        .font(.system(size: 56).bold().italic())
                }
                .scaleEffect(firstCircle)
                .opacity(workoutManager.running ? 2 - firstCircle : 0)
                
                Text(" bpm")
                    .font(.system(size: 28).bold().italic())
                    .foregroundStyle(.clear)
            }
            .foregroundStyle(.white)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                    firstCircle = 3
                }
            }
            
            // 두번째 파문
            HStack {
                Group {
                    Text(bpm, format: .number)
                        .font(.system(size: 56).bold().italic())
                }
                .scaleEffect(secondCircle)
                .opacity(workoutManager.running ? 2 - secondCircle : 0)
                
                Text(" bpm")
                    .font(.system(size: 28).bold().italic())
                    .foregroundStyle(.clear)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                    secondCircle = 2
                }
            }
        }
        .foregroundStyle(workoutManager.running ? textGradient : LinearGradient.stopBpm)
    }
}

#Preview {
    BPMTextView(textGradient: .zone3Bpm)
}
