//
//  MyCardView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/21.
//

import SwiftUI
import PhotosUI

struct MyCardView: View {
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @Binding var isFlipped: Bool
    @ObservedObject var viewModel: ProfileModel
    @EnvironmentObject var soundManager: SoundManager
    
    let width : CGFloat = 103
    let height : CGFloat = 138
    let durationAndDelay : CGFloat = 0.25
    
    func flipCard () {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    CardFront(width: width, height: height, degree: $frontDegree, viewModel: viewModel)
                    CardBack(width: width, height: height, degree: $backDegree)
                }
                .onTapGesture {
                    flipCard()
                    if isFlipped {
                        soundManager.playFrontSoundEffect()
                    } else {
                        soundManager.playBackSoundEffect()
                    }
                }
                .onChange(of: viewModel.imageSelection) { _ in
                    soundManager.playPhotoSelectEffect()
                }
            }
        }
    }
}

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    @State private var selectedItem: PhotosPickerItem?
    @ObservedObject var viewModel: ProfileModel
    
    var body: some View {
        ZStack {
            Profile(viewModel: viewModel,
                    width: width,
                    height: height)
                
            Image("ProfileLayer")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
            .background(.clear)
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            Image("MyCardBack")
                .resizable()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    MyCardView(isFlipped: .constant(true), viewModel: ProfileModel())
}

private struct PhotoPicker: View {
    
    @Binding var selectedItem: PhotosPickerItem?
    @ViewBuilder var label: any View
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                AnyView(label)
            }
    }
}
