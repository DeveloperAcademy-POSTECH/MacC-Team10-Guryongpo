//
//  CapsuleView.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/10/23.
//

import PhotosUI
import SwiftUI

struct PhotoSelectButtonView: View {
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        PhotosPicker(selection: $profileModel.imageSelection,
                     matching: .images,
                     photoLibrary: .shared()) {
            HStack {
                Image(systemName: "camera")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .overlay {
                        Capsule()
                            .stroke(style: .init(lineWidth: 1.0))
                            .foregroundColor(.brightmint)
                            .frame(width: 32, height: 32)
                    }
            }
        }
        .buttonStyle(.borderless)
    }
}
