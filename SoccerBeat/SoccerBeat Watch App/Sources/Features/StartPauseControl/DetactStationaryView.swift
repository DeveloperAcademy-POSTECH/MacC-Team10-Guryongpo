//
//  DetactStationaryView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/10/24.
//

import SwiftUI

struct DetactStationaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Finished\nyour workout?")
                    .font(.headline)
                    .overlay {
                        Image(.soccerbeatHeart)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .offset(x: 100)
                    }

                Spacer()

                // "End Workout" button
                Button {
                    workoutManager.endWorkout()
                    dismiss()
                } label: {
                    Text("경기 종료")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.mint.opacity(0.9))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)

                // "Pause" button
                Button {
                    workoutManager.togglePause()
                    dismiss()
                } label: {
                    Text("일시 정지")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gaugeBackground)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)

                Button {
                    dismiss()
                } label: {
                    Text("close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gaugeBackground)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    DetactStationaryView()
}
