////
////  BPMTextView.swift
////  SoccerBeat Watch App
////
////  Created by Gucci on 10/23/23.
////
//
import SwiftUI

struct BPMTextView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var firstCircle = 1.0
    @State private var secondCircle = 1.0
    let textGradient: LinearGradient
    
    var body: some View {
        ZStack {
            Color.clear
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(workoutManager.bpmForText)
                    .font(.beatPerMinute)
                
                Text(" bpm")
                    .font(.bpmUnit)
            }
            
            if workoutManager.running {
                LineBPMView()
            }
        }
        .foregroundStyle(workoutManager.running ? textGradient : .stopBpm)
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
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var pulsedHearts: [Particle] = []
    
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
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var startAnimation: Bool = false
    var body: some View {
        ZStack {
            Color.clear
    
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(workoutManager.bpmForText)
                    .font(.beatPerMinute)
                    .scaleEffect(startAnimation ? 3 : 1)
                    .opacity(startAnimation ? 0 : 0.2 )
                    .onAppear(perform: {
                        withAnimation(.linear(duration: 2)) {
                            startAnimation = true
                        }
                    })
                
                Text(" bpm")
                    .font(.bpmUnit)
                    .foregroundStyle(.clear)
            }
        }
        .foregroundStyle(.white)
        .ignoresSafeArea()
    }
}

#Preview {
    BPMTextView(textGradient: .zone3Bpm)
}
