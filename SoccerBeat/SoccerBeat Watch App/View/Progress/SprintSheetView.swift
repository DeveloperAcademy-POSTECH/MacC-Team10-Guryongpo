//
//  SprintSheetView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 11/16/23.
//

import SwiftUI

struct SprintSheetView: View {
    @State private var beatAnimation: Bool = false
    var speed: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            
            Image("alertButton")
                .resizable()
                .scaledToFit()
                .scaleEffect(beatAnimation ? 1.0 : 0.8)
                .animation(.smooth.repeatForever(autoreverses: true).speed(2.0), value: beatAnimation)
                .onAppear(perform: {
                    withAnimation {
                        beatAnimation.toggle()
                    }
                })
            VStack {
                Text("last SPRINT!")
                    .font(.lastSprint)
                    .foregroundStyle(.white)
                
                Text(speed)
                    .font(.alertSpeed)
                    .foregroundStyle(.zone1Bpm)
                
            }
        }.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .tint(.white)
                }
                    
            }
        }

    }
}

#Preview {
    SprintSheetView(speed: "10km/h")
}
