//
//  PhraseView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct PhraseView: View {
    var text: String = "..Like son\nGood\nPlayer"
    @State private var beatAnimation: Bool = true
    var body: some View {
        VStack {
            Text(text)
                .font(.title)
                .fontWeight(.black)
                .italic()
                .scaledToFill()
                .foregroundStyle(.zone2Bpm)
            Image("BlueHeart")
                .resizable()
                .scaledToFit()
                .scaleEffect(beatAnimation ? 1.1 : 1)
                .animation(.spring.repeatForever(autoreverses: true).speed(3), value: beatAnimation)
        }.onAppear(perform: {
            withAnimation {
                beatAnimation.toggle()
            }
        })
    }
}
    
    #Preview {
        PhraseView()
    }
