//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            ZStack {
                Image("BackgroundPattern")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 0)
                
                VStack {
                    MyCardView()
                    
                    Spacer()
                        .frame(height: 114)
                    
                    
                    MatchRecapView()
                    
                    Spacer()
                        .frame(height: 60)
                    
                    AnalyticsView()
                    
                    Spacer()
                        .frame(height: 60)
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
