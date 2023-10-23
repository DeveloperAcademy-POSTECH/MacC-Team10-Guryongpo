//
//  PauseView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

struct PauseView: View {
    var body: some View {
        VStack {
            Button {
                print("Button Tapped")
            } label: {
                Image(.timeOutButton)
                    .resizable()
                    .scaledToFill()
            }
            .buttonStyle(.plain)
            .clipShape(Circle())
        }    }
}

#Preview {
    PauseView()
}
