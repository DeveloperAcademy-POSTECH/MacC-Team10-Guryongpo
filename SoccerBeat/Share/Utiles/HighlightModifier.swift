//
//  HighlightModifier.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct HighlightModifier: ViewModifier {
    let activity: ActivityEnum
    
    init(activity: ActivityEnum) {
        self.activity = activity
    }
    
    var accentColor: Color {
        switch activity {
        case .distance:
            return .navigationSportyDistanceTitle
        case .sprint:
            return .navigationSportySprintTitle
        case .speed:
            return .navigationSportySpeedTitle
        case .heartrate:
            return .navigationSportyBPMTitle
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Rectangle()
                    .frame(height: 30)
                    .opacity(0.3)
                    .foregroundStyle(accentColor)
                    .offset(x: 0 , y: 15)
            }
    }
}

extension View {
    func highlighter(activity: ActivityEnum = .sprint) -> some View {
        modifier(HighlightModifier(activity: activity))
    }
}

#Preview {
    Group {
        Text("Hello")
        
        Text("World!")
            .foregroundStyle(Color(hex: 0xFF007A))
            .highlighter()
    }
    .font(.navigationSportyTitle)
}
