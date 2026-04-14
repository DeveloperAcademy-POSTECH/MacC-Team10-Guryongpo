//
//  BPMView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 4/8/24.
//

import SwiftUI

struct BPMView: View {
    @EnvironmentObject var matrics: MatricsIndicator
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var firstCircle = 1.0
    @State private var secondCircle = 1.0
    
    private var textGradient: LinearGradient {
        switch matrics.heartZone {
        case 1:
            return .zone1Bpm
        case 2:
            return .zone2Bpm
        case 3:
            return .zone3Bpm
        case 4:
            return .zone4Bpm
        default:
            return .zone5Bpm
        }
    }
    
    var body: some View {
        let text = Text(matrics.bpmForText)
        return ZStack {
            Color.clear
            // 기본 텍스트
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Group {
                    text
                        .kerning(-1.0)
                        .font(.beatPerMinute)
                        .overlay {
                            text
                                .kerning(-1.0)
                                .font(.beatPerMinute)
                                .viewBorder(color: .white, radius: CGFloat(0.15), outline: true)
                                .offset(x: 1.5, y: 3)
                        }
                    
                    Text("Bpm")
                        .font(.bpmUnit)
                }
            }

            if workoutManager.running {
                LineBPMView()
            }
        }
        .foregroundStyle(textGradient)
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ZStack {
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

struct Particle: Identifiable {
    var id: UUID = .init()
}

// MARK: BasicLineView 를 여러 개 퍼트려서 파동처럼 퍼지고 사라지게 만드는 뷰
struct LineBPMView: View {
    
    @EnvironmentObject var matrics: MatricsIndicator
    @State private var pulsedHearts: [Particle] = []
    
    var body: some View {
        VStack {
            ZStack {
                Color.clear
                TimelineView(.animation(minimumInterval: 1 - (Double(matrics.heartZone)/10), paused: false)) { timeline in
                    Canvas { context, size in
                        for heart in pulsedHearts {
                            if let resolvedView = context.resolveSymbol(id: heart.id) {
                                let centerX = size.width / 2
                                let centerY = size.height / 2
                                
                                context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY ))
                            }
                        }
                    } symbols: {
                        if matrics.isBPMActive {
                            ForEach(pulsedHearts) {
                                BasicLineView()
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
        }.ignoresSafeArea()
    }
}

// MARK: 파동처럼 퍼지는 기본 뷰
struct BasicLineView: View {
    
    @EnvironmentObject var matrics: MatricsIndicator
    @State private var startAnimation: Bool = false
    var body: some View {
        let text = Text(matrics.bpmForText)
        return ZStack {
            Color.clear
            // 기본 텍스트
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Group {
                    text
                        .font(.beatPerMinuteShadow)
                }
                .scaleEffect(startAnimation ? 3 : 1)
                .opacity(startAnimation ? 0 : 0.2 )
                .onAppear(perform: {
                    withAnimation(.linear(duration: 2)) {
                        startAnimation = true
                    }
                })

                Text(" Bpm")
                    .font(.bpmUnit)
                    .foregroundStyle(.clear)
            }
        }
        .foregroundStyle(.white)
        .ignoresSafeArea()
    }
}

#Preview {
    BPMView()
}
