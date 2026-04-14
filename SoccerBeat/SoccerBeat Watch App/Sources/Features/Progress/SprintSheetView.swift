//
//  SprintSheetView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 11/16/23.
//

import SwiftUI

struct SprintSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var beatAnimation = true
    let speedKPH: String
    
    var body: some View {
        ZStack(alignment: .center) {
                Image("alertButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(beatAnimation ? 1.0 : 1.1, anchor: .center)
                    .animation(.smooth.repeatForever(autoreverses: true).speed(2.0), value: beatAnimation)

            VStack {
                Text("last SPRINT!")
                    .font(.lastSprint)
                    .foregroundStyle(.white)
                
                Text(speedKPH)
                    .font(.alertSpeed)
                    .foregroundStyle(.zone1Bpm)
            }
        }

        .toolbar {
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
        .onAppear(perform: {
            withAnimation {
                beatAnimation.toggle()
            }
        })
        
    }
}

#Preview {
    SprintSheetView(speedKPH: "10km/h")
}
