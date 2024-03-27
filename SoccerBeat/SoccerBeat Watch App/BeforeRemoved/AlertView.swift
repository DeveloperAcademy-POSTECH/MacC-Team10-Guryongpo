//
//  AlertView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct AlertView: View {
    @Environment(\.dismiss) var dismiss
    @State private var beatAnimation = true
    private let alertMessage = "Zone 5!\nTake a\nBreath"
    
    var body: some View {
        ZStack {
            Image(.alertButton)
                .resizable()
                .scaledToFill()
                .padding()
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .animation(.smooth.repeatForever(autoreverses: true).speed(0.7), value: beatAnimation)
                .onAppear{
                    withAnimation {
                        beatAnimation.toggle()
                    }
                }.padding()
            
            Text(alertMessage)
                .font(.system(size: 30, weight: .black))
                .italic()
                .kerning(-1)
                .lineSpacing(-1.0)
                .multilineTextAlignment(.center)
            .foregroundStyle(LinearGradient(colors: [.white, .yellow], startPoint: .leading, endPoint: .trailing))
        }.toolbar {
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
