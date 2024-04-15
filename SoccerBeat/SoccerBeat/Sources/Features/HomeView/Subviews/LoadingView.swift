//
//  LoadingView.swift
//  SoccerBeat
//
//  Created by Gucci on 4/13/24.
//

import SkeletonUI
import SwiftUI

struct LoadingView: View {
    @Binding var workouts: [WorkoutData]
    
    var body: some View {
        ForEach(0..<6) { _ in
            ZStack {
                LightRectangleView()
                
                Text("Loading Now")
            }
            .skeleton(with: workouts.isEmpty)
        }
    }
}

#Preview {
    @State var examples: [WorkoutData] = []

    return LoadingView(workouts: $examples)
}
