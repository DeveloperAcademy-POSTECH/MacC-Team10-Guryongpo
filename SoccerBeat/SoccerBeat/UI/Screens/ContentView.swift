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
                    .frame(maxHeight: .infinity)
                
                VStack {
                    VStack {
                        MyCardView()
                        
                        Spacer()
                            .frame(height: 114)
                        
                        MatchRecapView()
                        
                        Spacer()
                            .frame(height: 60)
                        
                        AnalyticsView()
                        
                        Spacer()
                    }
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
