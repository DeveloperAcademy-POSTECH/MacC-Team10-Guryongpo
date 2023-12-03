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
    @AppStorage("userImage") var userImage: Data = .init()
    var image: UIImage? {
        let image = UIImage(data: userImage)
        return image
    }
    var body: some View {
        VStack {
            if self.image != nil {
                Image(uiImage: self.image!)
                    .resizable()
                    .frame(width: width, height: height)
                    .mask {
                        Image("MaskLayer")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                    }
            } else {
                
                EditableCircularProfileImage(viewModel: viewModel,
                                             width: width,
                                             height: height)
                .mask {
                    Image("MaskLayer")
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                }
            }
        }
    }
}
