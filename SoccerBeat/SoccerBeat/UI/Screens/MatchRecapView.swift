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
        MatchDetail(date: "2023.11.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4, heatmap: "Heatmap03"),
        MatchDetail(date: "2023.11.11", location: "지곡동", time: "94:12", distance: 1.3, velocity: 22, sprint: 3, heatmap: "Heatmap01"),
        MatchDetail(date: "2023.10.21", location: "산본동", time: "92:15", distance: 0.9, velocity: 21, sprint: 2, heatmap: "Heatmap02"),
        MatchDetail(date: "2023.9.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4, heatmap: "Heatmap03"),
        MatchDetail(date: "2023.11.11", location: "지곡동", time: "94:12", distance: 1.3, velocity: 22, sprint: 3, heatmap: "Heatmap01"),
        MatchDetail(date: "2023.10.21", location: "산본동", time: "92:15", distance: 0.9, velocity: 21, sprint: 2, heatmap: "Heatmap02"),
        MatchDetail(date: "2023.9.8", location: "흑석동", time: "101:13", distance: 1.5, velocity: 25, sprint: 4, heatmap: "Heatmap03")
    ]
    
    var monthly: [String: [MatchDetail]] {
        var dict = [String: [MatchDetail]]()
        matchitems.forEach { match in
            let yearMonth = Array(match.date.split(separator: ".")[...1]).joined(separator: ".")
            dict[yearMonth, default: []].append(match)
        }
        return dict
    }
}

struct MatchRecapView: View {
    @ObservedObject var matchItemData = MatchItemData()
    @State var showingMatchDetail = false
    @State var path: [NavigationStackViewType] = []
    
    enum NavigationStackViewType {
        case firstView
        case secondView
    }
    
    var body: some View {
//        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text("Hello, Son")
                        Text("Your archive")
                    }
                    .foregroundStyle(
                        .linearGradient(colors: [.hotpink, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    .kerning(-1.5)
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 60)
                
                HStack {
                    Spacer()
                        .frame(width: 30)
                    Text("최근 경기 기록")
                        .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                    Spacer()
                    Button(action: { path.append(.firstView) }) {
                        Text("모든 기록 보기 +")
                            .foregroundStyle(.white)
                            .font(.custom("NotoSansDisplay-BlackItalic", size: 14))
                    }
                    Spacer()
                        .frame(width: 30)
                }
                VStack {
                    ForEach(matchItemData.matchitems.prefix(3), id: \.self) { matchDetail in
                        ZStack {
                            MatchListItemView(matchDetail: matchDetail)
                        }
                    }
                }
            }
//            .navigationDestination(for: NavigationStackViewType.self) { navigationStackViewType in
//                switch navigationStackViewType {
//                case .firstView:
//                    AnalyticsDetailView(graphType: .BPM)
//                case .secondView:
//                    MatchDetailView()
//                }
//            }
//        }
    }
}

struct MatchListItemView: View {
    let matchDetail: MatchDetail
    
    var body: some View {
        ZStack {
            HStack {
                Spacer ()
                
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
            .padding(.vertical, 10)
            .overlay {
                LightRectangleView()
            }
        }
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

//#Preview {
//    let detail = MatchItemData().matchitems[0]
//    return MatchListItemView(matchDetail: detail)
//}
