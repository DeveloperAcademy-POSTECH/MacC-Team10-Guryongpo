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
            ScrollView {
                SummaryComponent(title: "뛴 거리",
                                 content: String(Measurement(value: workoutManager.distance,
                                   unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated, usage: .road))), playTime: "")
                SummaryComponent(title: "최고 속도", content: Measurement(value: workoutManager.maxSpeed, unit: UnitSpeed.kilometersPerHour).formatted(.measurement(width: .narrow, usage: .general)), playTime: "")
                SummaryComponent(title: "스프린트 횟수", content:  workoutManager.sprint.formatted() + " Times", playTime: "")
                
                SummaryComponent(title: "가속도", content:  Double(Int(workoutManager.acceleration * 100) / 100).formatted() + "m/s", playTime: "")
                
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
