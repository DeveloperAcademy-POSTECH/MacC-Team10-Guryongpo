//
//  ProfileImage.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import SwiftUI
import PhotosUI

// Render Image
struct ProfileImage: View {
    let imageState: ProfileModel.ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image.resizable()
        case .loading:
            ProgressView()
        case .empty:
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

// Transmit Profile ViewModel
struct EditableCircularProfileImage: View {
    @ObservedObject var viewModel: ProfileModel
    let width : CGFloat
    let height : CGFloat
    var body: some View {
        ProfileImage(imageState: viewModel.imageState)
            .frame(width: width, height: height)
    }
}
