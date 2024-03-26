//
//  MyCardView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/21.
//

import PhotosUI
import SwiftUI

struct MyCardView: View {
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var viewModel: ProfileModel
    @State private var backDegree = 0.0
    @State private var frontDegree = -90.0
    @Binding var isFlipped: Bool
    
    private let width = 100.0
    private let height = 140.0
    private let durationAndDelay = 0.25
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    CardFront(degree: $frontDegree, width: width, height: height)
                    CardBack(degree: $backDegree, width: width, height: height)
                }
                .onTapGesture {
                    flipCard()
                    
                    // sound control
                    isFlipped ? soundManager.playFrontSoundEffect() : soundManager.playBackSoundEffect()
                }
                .onChange(of: viewModel.imageSelection) { _ in
                    soundManager.playPhotoSelectEffect()
                }
            }
        }
    }
    
    func flipCard () {
        isFlipped.toggle()
        
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
}

struct CardFront : View {
    @EnvironmentObject var viewModel: ProfileModel
    @State private var selectedItem: PhotosPickerItem?
    @Binding var degree : Double
    let width : CGFloat
    let height : CGFloat
    
    var body: some View {
        ZStack {
            Profile(width: width,
                    height: height)
                
            Image(.profileLayer)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
            .background(.clear)
    }
}

struct CardBack : View {
    @Binding var degree : Double
    let width : CGFloat
    let height : CGFloat
    
    var body: some View {
        ZStack {
            Image(.myCardBack)
                .resizable()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    MyCardView(isFlipped: .constant(true))
}
