//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case statistic = 0
    case mycard
    case matchrecap
    
    var title: String {
        switch self {
        case .statistic:
            return "Analysis"
        case .mycard:
            return "My"
        case .matchrecap:
            return "Archive"
        }
    }
    
    var iconName: String {
        switch self {
        case .statistic:
            return "AnalysisTabIcon"
        case .mycard:
            return "MyTabIcon"
        case .matchrecap:
            return "ArchiveTabIcon"
        }
    }
}

struct ContentView: View {
    
    @State var selectedTab = 1
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                AnalyticsView()
                    .tag(0)
                
                MyCardView()
                    .tag(1)
                
                MatchRecapView()
                    .tag(2)
            }
        }
        
        ZStack {
            RoundedRectangle(cornerRadius: 35)
                .shadow(color: .white, radius: 8)
            RoundedRectangle(cornerRadius: 35)
                .blendMode(.destinationOut)
            RoundedRectangle(cornerRadius: 35)
                .strokeBorder(.white)
            RoundedRectangle(cornerRadius: 35)
                .fill(.white.opacity(0.6))
            
            HStack {
                ForEach((TabbedItems.allCases), id: \.self) { item in
                    Button (action: {
                        selectedTab = item.rawValue
                    }, label: {
                        CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                    })
                }
            }
        }
        .frame(width: 280, height: 60)
        .compositingGroup()
    }
}

extension ContentView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        VStack {
            Spacer()
            Image(isActive ? imageName + "Selected" : imageName + "NotSelected")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
            Spacer()
                .frame(height: 4)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.primary)
            Spacer()
        }
        .frame(width: 75)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
