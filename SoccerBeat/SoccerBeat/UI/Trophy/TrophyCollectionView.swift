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
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: nil) {
                InformationButton(message: "경기 기록에 따라 수집된 뱃지입니다.")
                  
                Group {
                    Text("Badge Collection")
                        .highlighter(activity: .sprint, isDefault: true)
                }
                .font(.navigationSportyTitle)
            }
            .padding(.horizontal, 10)
            
            trophyCollection
                .padding(.horizontal, 16)
        }
    }
    
    private func floatingBadgeInfo(at sort: Int) -> some View {
        var message = ""
        switch sort {
        case 0:
            message = "뛴 거리에 따라 획득하는 뱃지입니다."
        case 1:
            message = "스프린트 횟수에 따라 획득하는 뱃지입니다."
        default: // 2
            message = "최고 속도에 따라 획득하는 뱃지입니다."
        }
        
        return Text(message)
                .padding(.horizontal, 8)
                .floatingCapsuleStyle()
    }
}

#Preview {
    @StateObject var heathInteracter = HealthInteractor.shared
    return TrophyCollectionView()
        .environmentObject(heathInteracter)
}

extension TrophyCollectionView {
    @ViewBuilder
    var trophyCollection: some View {
        VStack(spacing: 31) {
            ForEach(0..<healthInteractor.allBadges.count, id: \.self) { sortIndex in
                VStack(alignment: .leading, spacing: 10) {
                    floatingBadgeInfo(at: sortIndex)
                    HStack {
                        ForEach(0..<healthInteractor.allBadges[sortIndex].count, id: \.self) { levelIndex in
                            let isOpened = healthInteractor.allBadges[sortIndex][levelIndex]
                            
                            TrophyView(sort: sortIndex, level: levelIndex, isOpened: isOpened)
                        }
                    }
                }
            }
        }
    }
}
