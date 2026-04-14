//
//  PhraseView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct PhraseView: View {
    @State private var beatAnimation = true

    var body: some View {
        VStack(spacing: nil) {
            Text(Phrase.randomElement.saying)
                .fixedSize(horizontal: false, vertical: true)
                .font(.wiseSaying)
                .multilineTextAlignment(.center)
                .foregroundStyle(.zone2Bpm)
                .frame(width: .infinity, height: 85)
            
            Spacer()
        
            Image(.blueHeart)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 25)
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .animation(.spring.repeatForever(autoreverses: true).speed(3),
                           value: beatAnimation)
        }
        .onAppear {
            beatAnimation.toggle()
        }
    }
}
    
#Preview {
    PhraseView()
}
