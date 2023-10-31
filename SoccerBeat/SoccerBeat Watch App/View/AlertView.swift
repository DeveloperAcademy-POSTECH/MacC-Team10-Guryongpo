//
//  AlertView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.


//

import SwiftUI

struct AlertView: View {
    @State private var beatAnimation: Bool = true
    var text: String = "Zone 5!\nTake a\nBreath"
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Image("alertButton")
                .resizable()
                .scaledToFill()
                .padding()
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .animation(.smooth.repeatForever(autoreverses: true).speed(0.7), value: beatAnimation)
                .onAppear(perform: {
                    withAnimation {
                        beatAnimation.toggle()
                    }
                }).padding()
            
            Text(text)
                .font(.system(size: 30, weight: .black))
                .italic()
                .kerning(-1)
                .lineSpacing(-1.0)
                .multilineTextAlignment(.center)
            .foregroundStyle(LinearGradient(colors: [.white, .yellow], startPoint: .leading, endPoint: .trailing))
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .tint(.white)
                }
                    
            }
        }

    }
}

#Preview {
    AlertView()
}
