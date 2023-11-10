//
//  Profile.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import SwiftUI
import PhotosUI

struct Profile: View {
    @ObservedObject var viewModel: ProfileModel
    let width : CGFloat
    let height : CGFloat
    var body: some View {
        NavigationView {
            EditableCircularProfileImage(viewModel: viewModel,
                                         width: width,
                                         height: height)
                .mask {
                    Image("MaskLayer")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
        }
    }
}
