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
    
    var body: some View {
        var text = Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
        return ZStack {
            // 기본 텍스트
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Group {
                    text
                        .font(.system(size: 56).bold().italic())
                }
                .scaleEffect(workoutManager.running ? 1.1 : 1)
                .animation(.spring.repeatForever(autoreverses: true).speed(2), value: workoutManager.running)

                Text(" bpm")
                    .font(.system(size: 18).bold().italic())
            }
        }
        .foregroundStyle(workoutManager.running ? textGradient : LinearGradient.stopBpm)
    }
}

#Preview {
    BPMTextView(textGradient: .zone3Bpm)
}
