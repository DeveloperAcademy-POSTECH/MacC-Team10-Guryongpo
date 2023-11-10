//
//  ElapsedTimeView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

struct ElapsedTimeView: View {
    let elapsedTime: TimeInterval
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var timeFormatter = ElapsedTimeFormatter()
    @State private var firstCircle = 1.0
    @State private var secondCircle = 1.0

    var body: some View {
        ZStack {
            Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
                .fixedSize(horizontal: true, vertical: false)
            
            if workoutManager.running {
                LineBPMView(elapsedTime: elapsedTime)
            }
        }
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        return formattedString
    }
}

private struct Particle: Identifiable {
    var id: UUID = .init()
}

// MARK: BasicLineView 를 여러 개 퍼트려서 파동처럼 퍼지고 사라지게 만드는 뷰
private struct LineBPMView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var pulsedHearts: [Particle] = []
    let elapsedTime: TimeInterval
    
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
