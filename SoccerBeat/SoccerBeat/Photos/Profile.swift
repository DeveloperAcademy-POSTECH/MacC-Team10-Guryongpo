//
//  Profile.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import SwiftUI

import SwiftUI
import PhotosUI

struct Profile: View {
    @StateObject var viewModel = ProfileModel()
    var body: some View {
        NavigationView {
            ZStack {
                Image("ProfileLayer")
                    .resizable()
                EditableCircularProfileImage(viewModel: viewModel)
            }
        }
    }
}
