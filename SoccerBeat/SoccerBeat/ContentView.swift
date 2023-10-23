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
            return "Archive"
        case .mycard:
            return "My"
        case .matchrecap:
            return "Archive"
        }
    }
    
    var iconName: String {
        switch self {
        case .statistic:
            return "doc.text"
        case .mycard:
            return "person.text.rectangle"
        case .matchrecap:
            return "figure.run"
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
        .frame(width: 260, height: 54)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
    }
}

extension ContentView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(isActive ? .blue : .secondary)
                .frame(width: 28, height: 28)
            Spacer()
                .frame(height: 1)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isActive ? .blue : .secondary)
            Spacer()
        }
        .frame(width: 72)
    }
}

#Preview {
    ContentView()
}
