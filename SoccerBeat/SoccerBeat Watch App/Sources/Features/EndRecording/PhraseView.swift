//
//  PhraseView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct PhraseView: View {
    @State private var beatAnimation = true
    private var phrase: String {
        if let decoded: PhraseResponse = Bundle.main.decode(by: "Phrase.json"),
           let phrase = decoded.phrase.randomElement() {
            return phrase.saying
        }
        return "..Like son\nGood\nPlayer"
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(phrase)
                .fixedSize(horizontal: false, vertical: true)
                .font(.wiseSaying)
                .multilineTextAlignment(.center)
                .foregroundStyle(.zone2Bpm)
            
            Spacer()
            
            Image(.blueHeart)
                .resizable()
                .scaledToFit()
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .frame(width: 42, height: 34)
                .animation(.spring.repeatForever(autoreverses: true).speed(3),
                           value: beatAnimation)
        }
        .onAppear {
            withAnimation {
                beatAnimation.toggle()
            }
        }
    }
}
    
#Preview {
    PhraseView()
}
