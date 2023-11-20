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
    
    private var imageName: String {
        isOpened 
        ? badgeUnlockedImages[sort][level]
        : badgeLockedImages[sort][level]
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    TrophyView(sort: 0, level: 1, isOpened: false)
}
