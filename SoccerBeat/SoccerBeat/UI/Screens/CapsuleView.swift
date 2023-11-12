//
//  CapsuleView.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/10/23.
//

import SwiftUI
import PhotosUI

struct PhotoSelectButtonView: View {
    @ObservedObject var viewModel: ProfileModel
    var body: some View {
        PhotosPicker(selection: $viewModel.imageSelection,
                     matching: .images,
                     photoLibrary: .shared()) {
            Text("사진 선택하기")
                .font(.selectPhotoButton)
                .foregroundStyle(.white)
                .padding(.horizontal)
                .overlay {
                    Capsule()
                        .stroke(style: .init(lineWidth: 0.8))
                        .foregroundColor(.brightmint)
                }
        }
        .buttonStyle(.borderless)
    }
}
