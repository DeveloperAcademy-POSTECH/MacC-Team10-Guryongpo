//
//  SprintView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/30/23.
//

import SwiftUI
import HealthKit

struct SprintView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    
    var body: some View {
        
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.white)
                    .frame(height: 21)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        ZStack {
                            ProgressView(value: min(matricsIndicator.speedMPS, matricsIndicator.sprintSpeed), total: matricsIndicator.sprintSpeed)
                                .progressViewStyle(GucciBarProgressStyle(accentGradient: .sprintOnGradient))
                                .padding(.horizontal, 2)
                            
                            HStack {
                                Spacer()
                                
                                if matricsIndicator.isSprint {
                                    Text("SPRINT!")
                                        .font(.sprintText)
                                        .padding(.horizontal)
                                } else {
                                    Text((matricsIndicator.speedMPS * 3.6).rounded(at: 1) + " km/h")
                                        .font(.sprintText)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                            .foregroundStyle(.white)
                        }
                    }
            }
        }
        .padding(.vertical)
    }
}

struct GucciBarProgressStyle: ProgressViewStyle {
    
    let accentGradient: LinearGradient
    private let cornerRadius = CGFloat(10.0)
    private let height: Double = 16.0
    
    func makeBody(configuration: Configuration) -> some View {
        
        let progress = configuration.fractionCompleted ?? .zero
        
        GeometryReader { geometry in
            ZStack {
                Color.clear
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(.clear)
                    .overlay(alignment: .leading) {
                        let cornerRaddi =  RectangleCornerRadii(topLeading: cornerRadius,
                                                                bottomLeading: cornerRadius,
                                                                bottomTrailing: cornerRadius,
                                                                topTrailing: cornerRadius)
                        
                        UnevenRoundedRectangle(cornerRadii: cornerRaddi)
                            .fill(accentGradient)
                            .frame(width: geometry.size.width * progress)
                    }
                    .frame(maxWidth: .infinity, maxHeight: height)
            }
        }
    }
}
