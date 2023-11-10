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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7 ) {
                        withAnimation {
                            isShowingSummary.toggle()
                        }
                    }
                }
        } else {
            ScrollView {
                SummaryComponent(title: "활동량", content: String(Measurement(value: workoutManager.distance,
                                                                           unit: UnitLength.meters)
                                         .formatted(.measurement(width: .abbreviated, usage: .road))), playTime: "")
                SummaryComponent(title: "최고 속도", content: Measurement(value: workoutManager.maxSpeed, unit: UnitSpeed.kilometersPerHour).formatted(.measurement(width: .narrow, usage: .general)), playTime: "")
                SummaryComponent(title: "스프린트 횟수", content:  workoutManager.sprint.formatted(), playTime: "")
                
                Button(action: { dismiss() }) {
                    Text("완료")
                        .font(.summaryDoneButton)
                        .foregroundStyle(.zone2Bpm)
                }
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
