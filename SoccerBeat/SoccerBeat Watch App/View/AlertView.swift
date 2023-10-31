//
//  AlertView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/31/23.
//

import SwiftUI

struct AlertView: View {
    @State private var beatAnimation: Bool = true
    var text: String = "Zone 5!\nTake a\nBreath "
    var body: some View {
        ZStack {
            Image("alertButton")
                .resizable()
                .scaledToFill()
            Text(text)
            .font(.system(size: 30))
            .bold()
            .italic()
            .multilineTextAlignment(.center)
            .foregroundStyle(LinearGradient(colors: [.white, .yellow], startPoint: .leading, endPoint: .trailing))
        }
        .scaleEffect(beatAnimation ? 1.1 : 1)
        .animation(.smooth.repeatForever(autoreverses: true).speed(0.7), value: beatAnimation)
        .onAppear(perform: {
            withAnimation {
                beatAnimation.toggle()
            }
        }).padding()
    }
}

#Preview {
    AlertView()
}
