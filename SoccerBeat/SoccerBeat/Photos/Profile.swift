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
    @State var image: UIImage?
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
                            .padding(8)
                    }
            } else {
                
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
        }.onAppear {
            if let imageData = UserDefaults.standard.object(forKey: "userImage") as? Data,
               let image = UIImage(data: imageData) {
                self.image = image
            }
        }
    }
}
