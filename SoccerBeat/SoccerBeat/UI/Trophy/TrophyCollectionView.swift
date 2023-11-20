//
//  TrophyCollectionView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct TrophyCollectionView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    
    var body: some View {
        VStack {
            ForEach(0..<healthInteractor.allBadges.count, id: \.self) { sortIndex in
                HStack {
                    ForEach(0..<healthInteractor.allBadges[sortIndex].count, id: \.self) { levelIndex in
                        
                        Text("s: \(sortIndex), l: \(levelIndex)")
                    }
                }
            }
        }
    }
}

#Preview {
    @StateObject var heathInteracter = HealthInteractor.shared
    return TrophyCollectionView()
        .environmentObject(heathInteracter)
}
