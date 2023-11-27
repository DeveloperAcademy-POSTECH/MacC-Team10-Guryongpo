//
//  SummaryView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State var isShowingSummary: Bool = false
    
    var body: some View {
        if !isShowingSummary {
            PhraseView()
                .navigationBarHidden(true)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 ) {
                        withAnimation {
                            isShowingSummary.toggle()
                        }
                    }
                }
        } else {
            ScrollView(showsIndicators: false) {
                SummaryComponent(title: "뛴 거리",
                                 content: (workoutManager.distance / 1000).rounded(at: 2) + " km")
                SummaryComponent(title: "최고 속도", content: (workoutManager.maxSpeed * 3.6).rounded(at: 1) + " km/h")
                SummaryComponent(title: "스프린트 횟수", content:  workoutManager.sprint.formatted() + "  Times")
                
                SummaryComponent(title: "가속도", content:  workoutManager.acceleration.rounded(at: 1) + " m/s")
                
                Button(action: { dismiss() }, label: {
                    Text("완료")
                        .font(.summaryDoneButton)
                        .foregroundStyle(.summaryGradient)
                })
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    SummaryView()
}
