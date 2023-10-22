//
//  StartView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack {
            Button {
                print("Button Tapped")
            } label: {
                Image(.startButton)
                    .resizable()
                    .scaledToFill()
            }
            // TODO: - adjusting Frame size
            .buttonStyle(.plain)
            .clipShape(Circle())
        }
    }
}

#Preview {
    StartView()
}
