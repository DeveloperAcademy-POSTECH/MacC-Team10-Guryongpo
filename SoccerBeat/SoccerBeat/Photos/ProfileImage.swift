//
//  ProfileImage.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import SwiftUI
import PhotosUI

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

struct CircularProfileImage: View {
    let imageState: ProfileModel.ImageState
    
    var body: some View {
        ProfileImage(imageState: imageState)
            .scaledToFill()
            .clipShape(.circle)
            .frame(width: 300, height: 300)
    }
}

struct EditableCircularProfileImage: View {
    @ObservedObject var viewModel: ProfileModel
    
    var body: some View {
        CircularProfileImage(imageState: viewModel.imageState)
            .overlay {
                PhotosPicker(selection: $viewModel.imageSelection,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Text("내 사진\n추가하기 +")
                }
                .buttonStyle(.borderless)
            }
    }
}
