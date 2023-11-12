//
//  ElapsedTimeView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

struct ElapsedTimeView: View {

    var body: some View {
        ZStack {
            Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
                .fixedSize(horizontal: true, vertical: false)
            
            if workoutManager.running {
                LineBPMView(elapsedTime: elapsedTime)
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Color.clear
                TimelineView(.animation(minimumInterval: 1 - (Double(workoutManager.heartZone)/10), paused: false)) { timeline in
                    Canvas { context, size in
                        for heart in pulsedHearts {
                            if let resolvedView = context.resolveSymbol(id: heart.id) {
                                let centerX = size.width / 2
                                let centerY = size.height / 2
                                
                                context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY ))
                            }
                        }
                    } symbols: {
                        if workoutManager.isBPMActive {
                            ForEach(pulsedHearts) {
                                BasicLineView(elapsedTime: elapsedTime)
                                    .id($0.id)
                            }
                        }
                    }
                    .onChange(of: timeline.date) { _ in
                        let pulsedHeart = Particle()
                        pulsedHearts.append(pulsedHeart)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            pulsedHearts.removeAll(where: { $0.id == pulsedHeart.id })
                        }
                        
                    }
                }
                
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: 파동처럼 퍼지는 기본 뷰
private struct BasicLineView: View {

    @State private var startAnimation = false
    @State private var timeFormatter = ElapsedTimeFormatter()
    let elapsedTime: TimeInterval
    
    var body: some View {
        ZStack {
            Color.clear
    
            Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
                .font(.beatPerMinute)
                .scaleEffect(startAnimation ? 3 : 1)
                .opacity(startAnimation ? 0 : 0.2 )
                .onAppear(perform: {
                    withAnimation(.linear(duration: 2)) {
                        startAnimation = true
                    }
                })
        }
        .foregroundStyle(.white)
        .ignoresSafeArea()
    }
}
