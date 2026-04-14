//
//  ElapsedTimeView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

// TODO: -
struct ElapsedTimeView: View {
    private let spendingTimeDevidedColone: [String]
    
    init(elapsedSec: TimeInterval) {
        self.spendingTimeDevidedColone = ElapsedTimeFormatter()
                                            .spendingTimeDevidedColone(elapsedSec)
    }
    
    // TODO: - 여기 나오는 매직 넘버가 왜 그런 값을 가지게 되었는지 이유가 필요
    var body: some View {
        let radius = CGFloat(0.15)
        HStack(alignment: .center, spacing: 0) {
            // MARK: - Minute
            HStack {
                Text(spendingTimeDevidedColone[0])
                    .kerning(-0.9)
                    .overlay {
                        Text(spendingTimeDevidedColone[0])
                            .allowsTightening(false)
                            .kerning(-0.9)
                            .viewBorder(color: .white, radius: radius, outline: true)
                            .offset(x: 2, y: 2.5)
                    }
                if spendingTimeDevidedColone[0].count < 3 {
                    Spacer()
                }
            }
            
            Text(":")
                .overlay {
                    Text(":")
                        .viewBorder(color: .white, radius: radius, outline: true)
                        .offset(x: 1, y: 1.5)
                }
                .frame(width: 13)
            
            HStack {
                
                if spendingTimeDevidedColone[0].count < 3 {
                    Spacer()
                }
                
                Text(spendingTimeDevidedColone[1])
                    .kerning(-0.9)
                    .overlay {
                        Text(spendingTimeDevidedColone[1])
                            .allowsTightening(false)
                            .kerning(-0.9)
                            .viewBorder(color: .white, radius: radius, outline: true)
                            .offset(x: 2, y: 2.5)
                    }
            }
        }
        .font(.playTimeNumber)
        .foregroundStyle(.zone2Bpm)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ElapsedTimeView(elapsedSec: .init(floatLiteral: 2684))
}
