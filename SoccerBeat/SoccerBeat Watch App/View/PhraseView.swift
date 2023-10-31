//
//  PhraseView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct PhraseView: View {
    @State private var text: String = "..Like son\nGood\nPlayer"
    @State private var beatAnimation: Bool = true
    var body: some View {
        VStack(spacing: 18) {
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 18))
                .scaledToFit()
                .fontWeight(.black)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.zone2Bpm)
            
            Image("BlueHeart")
                .resizable()
                .scaledToFit()
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .frame(width: 42, height: 34)
                .animation(.spring.repeatForever(autoreverses: true).speed(3), value: beatAnimation)
        }.onAppear(perform: {
            withAnimation {
                beatAnimation.toggle()
            }
        })
        .onAppear {
            if let decoded: PhraseResponse = Bundle.main.decode(by: "Phrase.json"),
               let phrase = decoded.phrase.randomElement() {
                self.text = phrase.saying
            }
        }
    }
}
    
#Preview {
    PhraseView()
}
