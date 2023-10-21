//
//  SoccerBeatApp.swift
//  SoccerBeat
//
//  Created by geee3 on 10/21/23.
//

import SwiftUI

@main
struct SoccerBeatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
