//
//  MyCardView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/21.
//

import SwiftUI

struct MyCardView: View {
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = false
    
    let width : CGFloat = 242
    let height : CGFloat = 396
    let durationAndDelay : CGFloat = 0.15
    
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
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            Image("HeartBeatSign")
            
            VStack {
                Spacer()
                    .frame(height: 100)
                
                VStack(alignment: .leading) {
                    Text("Hello, Son")
                    Text("why always me?")
                }
                .foregroundStyle(
                    .linearGradient(colors: [.skyblue, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.custom("SFProText-HeavyItalic", size: 36))
                
                Spacer()
                    .frame(height: 35)
                
                ZStack {
                    CardFront(width: width, height: height, degree: $frontDegree)
                    CardBack(width: width, height: height, degree: $backDegree)
                }.onTapGesture {
                    flipCard()
                }
                
                Spacer()
            }
            
        }
    }
}

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            Image("CardFront")
                .resizable()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white, lineWidth: 1)
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .opacity(0.5)
                )
            Image("HeartShape")
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    MyCardView()
}
