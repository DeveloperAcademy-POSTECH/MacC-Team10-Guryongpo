//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

class MatchItemData: ObservableObject {
    @Published var matchitems = [
        MatchItem(date: "2023.11.11", location: "지곡동", time: "94:12", distance: 1.3, velocity: 22, sprint: 3),
        MatchItem(date: "2023.10.21", location: "산본동", time: "92:15", distance: 0.9, velocity: 21, sprint: 2),
        MatchItem(date: "2023.9.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4),
        MatchItem(date: "2023.7.5", location: "효자동", time: "74:12", distance: 3.3, velocity: 30, sprint: 7)
    ]
}

struct MatchRecapView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hello, Son")
                        Text("Your archive")
                    }
                    .foregroundStyle(
                        .linearGradient(colors: [.hotpink, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    Spacer()
                }
                Spacer()
                    .frame(height: 50)
                
                HStack {
                    Image("HeartShapeGray")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Archive")
                        .foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(50)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Spacer()
                }
                
                MatchListItemView()
            }
        }
    }
}

struct MatchListItemView: View {
    @ObservedObject var matchItemData = MatchItemData()
    @State private var showModal = false
    
    var body: some View {
        List {
            ForEach(matchItemData.matchitems, id: \.self) { matchitem in
                Button(action: {
                    self.showModal = true
                }) {
                    Rectangle()
                        .foregroundStyle(.white)
                        .overlay {
                            HStack {
                                Circle()
                                    .foregroundStyle(.pink)
                                    
                                Text(matchitem.date)
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .frame(height: 400)
    }
}

struct MatchItem: Identifiable, Hashable {
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
