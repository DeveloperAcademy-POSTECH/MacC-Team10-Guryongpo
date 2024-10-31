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
        ProgressView()
    }
}

#Preview {
    @StateObject var healthInteractor = HealthInteractor.shared

    return LoadingView()
        .environmentObject(healthInteractor)
}
