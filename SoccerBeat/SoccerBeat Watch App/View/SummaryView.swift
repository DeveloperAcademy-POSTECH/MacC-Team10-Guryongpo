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
                SummaryComponent(title: "활동량", content: "2.1Km", playTime: "전반 25분")
                SummaryComponent(title: "최고속도", content: "18Km/h", playTime: "전반 25분")
                SummaryComponent(title: "스프린트 횟수", content: "6 times", playTime: "전반 25분")
                SummaryComponent(title: "칼로리", content: "200 Kcal", playTime: "전반 25분")
                
                Button(action: { dismiss() }) {
                    Text("완료")  // TODO: Font Design Pattern 추후 추가
                        .font(.title3)
                        .bold()
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
