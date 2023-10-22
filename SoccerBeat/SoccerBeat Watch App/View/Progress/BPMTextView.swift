////
////  BPMTextView.swift
////  SoccerBeat Watch App
////
////  Created by Gucci on 10/23/23.
////
//
import SwiftUI

struct BPMTextView: View {
    @State private var firstCircle = 1.0
    @State private var secondCircle = 1.0
    let textGradient: LinearGradient
    let bpm: Int
    
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
            Group {
                Text(bpm, format: .number)
                    .font(.system(size: 56).bold().italic())
                + Text(" bpm")
                    .font(.system(size: 28).bold().italic())
            }
            .foregroundStyle(.white)
            .scaleEffect(firstCircle)
            .opacity(2 - firstCircle)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                    firstCircle = 3
                }
            }
            
            // 두번째 파문
            Group {
                Text(bpm, format: .number)
                    .font(.system(size: 56).bold().italic())
                + Text(" bpm")
                    .font(.system(size: 28).bold().italic())
            }
            .scaleEffect(secondCircle)
            .opacity(2 - secondCircle)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                    secondCircle = 2
                }
            }
        }
        .foregroundStyle(textGradient)
    }
}

#Preview {
    BPMTextView(textGradient: .zone3Bpm, bpm: 120)
}
