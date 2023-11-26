//
//  ElapsedTimeView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

struct ElapsedTimeView: View {
    private let spendingTimeDevidedColone: [String]
    
    init(elapsedTime: TimeInterval) {
        self.spendingTimeDevidedColone = ElapsedTimeFormatter()
            .spendingTimeDevidedColone(elapsedTime)
    }
    
    var body: some View {
        let radius = CGFloat(0.15)
        HStack(alignment: .center, spacing: 0) {
            // MARK: - Minute
            Text(spendingTimeDevidedColone[0])
                .kerning(-0.9)
                .overlay {
                    Text(spendingTimeDevidedColone[0])
                        .kerning(-0.9)
                        .viewBorder(color: .white, radius: radius, outline: true)
                        .offset(x: 2, y: 2.5)
                }
                .frame(width: spendingTimeDevidedColone[0].count == 3 ? 84 : 56)
            
            if spendingTimeDevidedColone[0].count != 3 {
                Spacer()
            }
            
            Text(":")
                .overlay {
                    Text(":")
                        .viewBorder(color: .white, radius: radius, outline: true)
                        .offset(x: 1, y: 1.5)
                }
                .frame(width: 13)
            
            if spendingTimeDevidedColone[0].count != 3 {
                Spacer()
            }
            
            Text(spendingTimeDevidedColone[1])
                .kerning(-0.9)
                .overlay {
                    
                    Text(spendingTimeDevidedColone[1])
                        .kerning(-0.9)
                        .viewBorder(color: .white, radius: radius, outline: true)
                        .offset(x: 2, y: 2.5)
                }
                .frame(width: 56)
        }
        .font(.playTimeNumber)
        .foregroundStyle(.gameTimeGradient)
    }
}

#Preview {
    ElapsedTimeView(elapsedTime: .init(floatLiteral: 2684))
}
