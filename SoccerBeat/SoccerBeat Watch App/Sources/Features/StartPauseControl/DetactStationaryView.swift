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
                    Text("End Workout")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.mint)
                        .cornerRadius(12)
                }
                .padding(.bottom, 10)

                // "Pause" button
                Button {
                    workoutManager.togglePause()
                    dismiss()
                } label: {
                    Text("Pause")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
                .padding(.bottom, 10)

                // "Close" button
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
    }
}

//#Preview {
//    DetactStationaryView()
//}
