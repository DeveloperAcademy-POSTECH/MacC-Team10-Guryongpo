//
//  TrophyCollectionView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct TrophyCollectionView: View {
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: nil) {
                InformationButton(message: "경기 기록에 따라 수집된 뱃지입니다.")
                
                Text("Badge Collection")
                    .font(.navigationSportyTitle)
                    .highlighter(activity: .sprint, isDefault: true)
            }
            .padding(.horizontal, 10)
            
            trophyCollection
                .padding(.horizontal, 16)
        }
    }
}

extension TrophyCollectionView {
    private func floatingBadgeInfo(at sort: Int) -> some View {
        var message = ""
        switch sort {
        case 0:
            message = "뛴 거리에 따라 획득하는 뱃지입니다."
        case 1:
            message = "스프린트 횟수에 따라 획득하는 뱃지입니다."
        default:
            message = "최고 속도에 따라 획득하는 뱃지입니다."
        }
        
        return Text(LocalizedStringKey(message))
            .padding(.horizontal, 8)
            .floatingCapsuleStyle()
    }
    
    @ViewBuilder
    var trophyCollection: some View {
        VStack(spacing: 31) {
            ForEach(0..<profileModel.allBadges.count, id: \.self) { sortIndex in
                VStack(alignment: .leading, spacing: 10) {
                    floatingBadgeInfo(at: sortIndex)
                    HStack {
                        ForEach(0..<profileModel.allBadges[sortIndex].count, id: \.self) { levelIndex in
                            let isOpened = profileModel.allBadges[sortIndex][levelIndex]
                            
                            TrophyView(sort: sortIndex, level: levelIndex, isOpened: isOpened)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @StateObject var profileModel = ProfileModel(healthInteractor: HealthInteractor.shared)
    
    return TrophyCollectionView()
        .environmentObject(profileModel)
}
