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
            HStack {
                Image(systemName: "camera")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .overlay {
                        Capsule()
                            .stroke(style: .init(lineWidth: 0.8))
                            .foregroundColor(.brightmint)
                            .frame(width: 24, height: 24)
                    }
//                NavigationLink {
//                    ShareView(viewModel: viewModel)
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.selectPhotoButton)
//                        .foregroundStyle(.white)
//                        .padding()
//                        .overlay {
//                            Circle()
//                                .stroke(style: .init(lineWidth: 0.8))
//                                .foregroundColor(.brightmint)
//                                .frame(width: 34, height: 34)
//                        }
//                }
            }
        }
        .buttonStyle(.borderless)
    }
}
