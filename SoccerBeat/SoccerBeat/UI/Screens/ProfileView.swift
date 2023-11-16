//
//  ProfileView.swift
//  SoccerBeat
//
//  Created by daaan on 11/17/23.
//

import SwiftUI

struct ProfileView: View {
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        VStack {
            MyCardView(isFlipped: $isFlipped, viewModel: viewModel)
        }
    }
}

#Preview {
    ProfileView()
}
