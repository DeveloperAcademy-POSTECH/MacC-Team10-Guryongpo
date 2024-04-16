//
//  LoadingView.swift
//  SoccerBeat
//
//  Created by Gucci on 4/13/24.
//

import SkeletonUI
import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    
    var body: some View {
        ForEach(0..<6) { _ in
            Text("Loading Now")
                .skeleton(with: healthInteractor.isLoading)
        }
    }
}

#Preview {
    @StateObject var healthInteractor = HealthInteractor.shared

    return LoadingView()
        .environmentObject(healthInteractor)
}
