//
//  TrophyView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct TrophyView: View {
    @State private var showTooltip = false
    let sort: Int
    let level: Int
    let isOpened: Bool
    
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
                TooltipView(isVisible: $showTooltip, alignment: .top) {
                    Text(LocalizedStringKey(infoMessagss))
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
