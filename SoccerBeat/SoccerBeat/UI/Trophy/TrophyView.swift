//
//  TrophyView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct TrophyView: View {
    let sort: Int
    let level: Int
    let isOpened: Bool
    @State private var showTooltip = false
    
    private var imageName: String {
        isOpened 
        ? badgeUnlockedImages[sort][level]
        : badgeLockedImages[sort][level]
    }
    
    private var infoMessagss: String {
        return badgeInfo[sort][level]
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .overlay {
                TooltipView(alignment: .top, isVisible: $showTooltip) {
                    Text(infoMessagss)
                        .foregroundStyle(.tooltipTextColor)
                        .font(.tooltipTextFont)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .onTapGesture(perform: toggleTooltipWithAnimation)
    }
    
    private func toggleTooltipWithAnimation() {
        showTooltip = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showTooltip = false
            }
        }
    }
}

#Preview {
    TrophyView(sort: 0, level: 1, isOpened: false)
}
