//
//  SoccerBeatApp.swift
//  SoccerBeat Watch App
//
//  Created by daaan on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeat_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }.sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .onAppear {

                for family in UIFont.familyNames.sorted() {
                    print("Family: \(family)")
                    
                    let names = UIFont.fontNames(forFamilyName: family)
                    for fontName in names {
                        print("- \(fontName)")
                    }
                }
            }
            .environmentObject(workoutManager)
        }
    }
}
