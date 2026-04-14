//
//  Profile.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import PhotosUI
import SwiftUI

struct Profile: View {
    @AppStorage("userImage") var userImage: Data = .init()
    let width : CGFloat
    let height : CGFloat
    private var image: UIImage? {
        let image = UIImage(data: userImage)
        return image
    }
    
    var body: some View {
        VStack {
            if let profileImage = self.image {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .mask {
                        Image(.maskLayer)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                    }
            } else {
                // TODO: - 로직 흐름에서 여기가 불릴 일이 없는 것 같습니다.
                EditableCircularProfileImage(width: width,
                                             height: height)
                    .mask {
                        Image(.maskLayer)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                    }
            }
        }
    }
}
