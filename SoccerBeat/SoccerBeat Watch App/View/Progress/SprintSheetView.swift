//
//  SprintSheetView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 11/16/23.
//

import SwiftUI

struct SprintSheetView: View {
    @State private var beatAnimation: Bool = true
    var speed: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .center) {
                Image("alertButton")
                    .resizable()
                    .scaledToFit()
                    .animation(.smooth.repeatForever(autoreverses: true).speed(2.0), value: beatAnimation)
                    .scaleEffect(beatAnimation ? 1.0 : 1.01, anchor: .topLeading)
            
            VStack {
                Text("last SPRINT!")
                    .font(.lastSprint)
                    .foregroundStyle(.white)
                
                Text(speed)
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
    SprintSheetView(speed: "10km/h")
}
