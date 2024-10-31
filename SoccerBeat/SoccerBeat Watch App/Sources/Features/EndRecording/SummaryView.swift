//
//  SummaryView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    @State private var isShowingSummary = false
    @State private var selection: SummarySort = .sportsInfo
    @State var isBlinking = false
    @State var isHeartBlinking = false
    
    private enum SummarySort {
        case sportsInfo, heartInfo
    }
    
    var body: some View {
        if isShowingSummary {
            GeometryReader { proxy in
                TabView {
                    Group {
                        VStack(spacing: 4) {
                            
                            InfoSportsView()
                                .padding(.top)
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundStyle(.summaryGradient)
                                .font(.summaryTraillingTop)
                                .opacity(isBlinking ? 1 : 0)
                                .animation(.spring.repeatForever(autoreverses: false).speed(0.8),
                                           value: isBlinking)
                                .padding(.bottom)
                        }
                        
                        VStack(spacing: 4) {
                            
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundStyle(.summaryGradient)
                                .font(.summaryTraillingTop)
                                .opacity(isHeartBlinking ? 1 : 0)
                                .animation(.spring.repeatForever(autoreverses: false).speed(0.8),
                                           value: isHeartBlinking)
                                .padding(.top)
                            InfoHeartView()
                            Spacer()
                            Button {
                                workoutManager.showingSummaryView = false
                            } label: {
                                Capsule()
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .foregroundStyle(Color.columnContent)
                                    .overlay {
                                        Text("완료")
                                            .font(.summaryDoneButton)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 24)
                                            .foregroundStyle(.summaryGradient)
                                    }
                            }
                            .padding(.bottom, 16)
                            
                        }
                        .onAppear {
                            withAnimation {
                                isHeartBlinking = true
                                print("heart", isHeartBlinking)
                            }
                         }
                    }
                    .frame(
                        width: proxy.size.width - 10.0,
                        height: proxy.size.height - 10.0
                    )
                    .padding()
                    .onAppear {
                        withAnimation {
                            isBlinking = true
                        }
                    }
                }
                .tabViewStyle(.carousel)
                .scrollIndicators(.hidden)
                
            }
            .edgesIgnoringSafeArea(.all)
        } else {
            PhraseView()
                .navigationBarHidden(true)
                .task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                    withAnimation {
                        isShowingSummary.toggle()
                        workoutManager.showingPrecount = false
                    }
                }
        }
    }
}

struct InfoSportsView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                SummaryComponent(title: "뛴 거리_",
                                 content: (matricsIndicator.distanceMeter / 1000).rounded(at: 0), unit: "km")
                SummaryComponent(title: "최고 속도", content: (matricsIndicator.maxSpeedMPS * 3.6).rounded(at: 0), unit: "km/h")
            }
            HStack(spacing: 4) {
                SummaryComponent(title: "스프린트", content:  matricsIndicator.sprintCount.formatted(), unit: "Times")
                SummaryComponent(title: "파워", content:  matricsIndicator.power.rounded(at: 0), unit: "w")
            }
        }
    }
}

struct InfoHeartView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    var body: some View {
        HStack(spacing: 4) {
            SummaryComponent(title: "최소심박",
                             content: (matricsIndicator.saveMinHeartRate).formatted(), unit: "Bpm")
            SummaryComponent(title: "최대심박", content: (matricsIndicator.saveMaxHeartRate).formatted(), unit: "Bpm")
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(DIContianer.makeWorkoutManager())
        .environmentObject(DIContianer.makeMatricsIndicator())
}
