//
//  HighlightModifier.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct HighlightModifier: ViewModifier {
    let activity: ActivityEnum
    let isDefault: Bool
    
    init(activity: ActivityEnum, isDefault: Bool = false) {
        self.activity = activity
        self.isDefault = isDefault
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
                    .foregroundStyle(isDefault ? .init(hex: 0x6D6D6D) : accentColor)
                    .offset(x: 0 , y: 15)
            }
    }
}

extension View {
    func highlighter(activity: ActivityEnum = .sprint, isDefault: Bool = false) -> some View {
        modifier(HighlightModifier(activity: activity, isDefault: isDefault))
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
