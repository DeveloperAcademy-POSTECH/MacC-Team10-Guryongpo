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
    
    let width : CGFloat = 321
    let height : CGFloat = 445
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
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                Image("HeartBeatSign")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 229)
                    .blur(radius: 5)
                    .opacity(0.2)
                Spacer()
                    .frame(height: 230)
            }
            
            VStack {                
                HStack {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text("Hello, Son")
                        Text("Are you")
                        Text("World class?")
                    }
                    .foregroundStyle(!isFlipped ?
                        .linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing) : .linearGradient(colors: [.titlegray, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    .kerning(-1.5)
                    .padding(.leading, 10.0)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
                
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
            Image("MyCardFront")
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
            Image("MyCardBack")
                .resizable()
                .frame(width: width, height: height)
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    MyCardView()
}