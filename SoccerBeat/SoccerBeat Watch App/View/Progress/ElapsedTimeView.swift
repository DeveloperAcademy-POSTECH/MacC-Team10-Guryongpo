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
        self.spendingTimeDevidedColone = ElapsedTimeFormatter().spendingTimeDevidedColone(elapsedTime)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - Minute
            ZStack {
                Text(spendingTimeDevidedColone[0])
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(spendingTimeDevidedColone[0])
                    .fixedSize(horizontal: true, vertical: false)
                    .viewBorder(color: .white, radius: 0.15, outline: true)
                    .offset(x: 3, y: 3.5)
            }
            
            Text(":")
            
            Spacer()
        }
        .overlay(alignment: .trailing) {
            // MARK: - Second
            ZStack {
                Text(spendingTimeDevidedColone[1])
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(spendingTimeDevidedColone[1])
                    .fixedSize(horizontal: true, vertical: false)
                    .viewBorder(color: .white, radius: 0.15, outline: true)
                    .offset(x: 3, y: 3.5)
            }
            .multilineTextAlignment(.trailing)
        }
        .font(.playTimeNumber)
        .foregroundStyle(.playTimeNumber)
    }
}

#Preview {
    ElapsedTimeView(elapsedTime: .init(floatLiteral: 2684))
}
