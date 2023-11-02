//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var healthInteractor = HealthInteractor.shared
    var body: some View {
        NavigationStack {
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
                        
                        NavigationLink {
                            MatchRecapView()
                        } label: {
                            Text("마음 속으로 3초 세고 누르기! 잇힝 >-<")
                        }
                        
                        Spacer()
                            .frame(height: 60)
                        
                        AnalyticsView()
                        
                        Spacer()
                            .frame(height: 60)
                        
                    }
                }
            }
        }
        .environmentObject(healthInteractor)
        .task {
            await healthInteractor.fetchAllData()
            print("stop ..")
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
