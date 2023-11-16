//
//  BackgroundImageView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/15/23.
//

import SwiftUI

struct BackgroundImageView: View {
    var body: some View {
        Image(.backgroundPattern)
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .frame(height: .zero)
    }
}

#Preview {
    BackgroundImageView()
}
