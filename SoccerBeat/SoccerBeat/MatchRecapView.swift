//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchRecapView: View {
    let matchitems = [
        MatchItem(date: "2023.11.11", location: "지곡동", time: "94:12", distance: 1.3, velocity: 22, sprint: 3),
        MatchItem(date: "2023.10.21", location: "산본동", time: "92:15", distance: 0.9, velocity: 21, sprint: 2),
        MatchItem(date: "2023.9.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4),
        MatchItem(date: "2023.7.5", location: "효자동", time: "74:12", distance: 3.3, velocity: 30, sprint: 7)
    ]
    
    var body: some View {
        MatchListItemView()
    }
}

struct MatchListItemView: View {
    var body: some View {
        Text("ListItemView")
    }
}

struct MatchItem: Identifiable {
    let id = UUID()
    let date: String
    let location: String
    let time: String
    let distance: Float
    let velocity: Int
    let sprint: Int
}

#Preview {
    MatchRecapView()
}
