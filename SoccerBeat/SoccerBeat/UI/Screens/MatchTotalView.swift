//
//  MatchTotalView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/1/23.
//

import SwiftUI

struct MatchTotalView: View {
    @StateObject private var matchData = MatchItemData()
    let userName = "Son"
    
    var body: some View {
        ScrollView {
            
            // MARK: - Title
            
            HStack {
                title
                
                Spacer()
            }
            
            ForEach(Array(matchData.monthly.keys), id: \.self) { monthDate in
                Section {
                    
                    // MARK: - Match Details List
                    
                    ForEach(matchData.monthly[monthDate, default: []]) { matchDetail in
                        
                        NavigationLink {
                            MatchDetailView()
                        } label: {
                            MatchListItemView(matchDetail: matchDetail)
                                .padding(10)
                        }
                    }
                } header: {
                    
                    // MARK: - Section Header
                    
                    HStack {
                        Image(.heartShapeGray)
                            .resizable()
                            .frame(width: 16, height: 15)
                            .scaledToFit()
                        
                        Text(monthDate)
                            .font(.matchTotalSectionHeader)
                            .foregroundStyle(.matchTotalSectionHeader)
                        Spacer()
                    }
                    .padding(.leading, 27)
                }
            }
        }
    }
}

extension MatchTotalView {
    @ViewBuilder private var title: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Text("Hello, \(userName)")
            Text("Your archive")
        }
        .foregroundStyle(.matchTotalTitle)
        .font(.matchTotalTitle)
        .kerning(-1.5)
        .padding(.leading, 27)
    }
}

#Preview {
        MatchTotalView()
}
