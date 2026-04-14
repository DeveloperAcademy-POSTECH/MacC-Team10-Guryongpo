//
//  OnboardingView.swift
//  SoccerBeat
//
//  Created by Henry's Mac on 7/12/24.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
                
            }
            Spacer()
            Text("workout_empty")
                .font(.onboardingTop)
                .foregroundStyle(.onboardingText)
            Image("OnboardingWatchImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
            Text("try_game_in_watch")
                .font(.onboardingBottom)
                .foregroundStyle(.onboardingText)
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
