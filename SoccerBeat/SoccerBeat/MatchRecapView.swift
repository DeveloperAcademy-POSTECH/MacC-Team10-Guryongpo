//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

class MatchItemData: ObservableObject {
    @Published var matchitems = [
        MatchDetail(date: "2023.11.11", location: "지곡동", time: "94:12", distance: 1.3, velocity: 22, sprint: 3, heatmap: "Heatmap01"),
        MatchDetail(date: "2023.10.21", location: "산본동", time: "92:15", distance: 0.9, velocity: 21, sprint: 2, heatmap: "Heatmap02"),
        MatchDetail(date: "2023.9.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4, heatmap: "Heatmap03"),
//        MatchDetail(date: "2023.7.5", location: "효자동", time: "74:12", distance: 3.3, velocity: 30, sprint: 7, heatmap: "Heatmap01")
    ]
}

struct MatchRecapView: View {
    @ObservedObject var matchItemData = MatchItemData()
    @State var showingMatchDetail = false
    
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
                .padding()
                
                List {
                    ForEach(matchItemData.matchitems, id: \.self) { matchDetail in
                        MatchListItemView(matchDetail: matchDetail)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                showingMatchDetail.toggle()
                            }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            }
        }.sheet(isPresented: $showingMatchDetail, content: {
            MatchDetailView()
                .presentationDetents([.height(630), .large])
        })
    }
}

struct MatchListItemView: View {
    let matchDetail: MatchDetail
    
    var body: some View {
        ZStack {
            HStack {
                Image("\(matchDetail.heatmap)")
                    .resizable()
                    .frame(width: 80, height: 120)
                    .padding(.leading, 5)
                
                VStack(alignment: .leading) {
                    Text(matchDetail.date + " - " + matchDetail.location)
                        .foregroundStyle(Color.white.opacity(0.5))
                    Text("경기 시간 " + matchDetail.time)
                        .foregroundStyle(Color.white)
                        .padding(.bottom)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("활동량")
                            Text(String(format: "%.1f", matchDetail.distance) + "km")
                        }.foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                        
                        VStack(alignment: .leading) {
                            Text("최고 속도")
                            Text("\(matchDetail.velocity)km/h")
                        }.foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                        
                        VStack(alignment: .leading) {
                            Text("스프린트 횟수")
                            Text("\(matchDetail.sprint)회")
                        }
                        .foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }.listRowBackground(Color.clear)
    }
}

struct MatchDetail: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let location: String
    let time: String
    let distance: Float
    let velocity: Int
    let sprint: Int
    let heatmap: String
}

#Preview {
    MatchRecapView()
}
