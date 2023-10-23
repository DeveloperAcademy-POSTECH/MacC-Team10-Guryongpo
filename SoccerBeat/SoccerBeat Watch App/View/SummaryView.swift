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
                SummaryComponent(title: "활동량", content: "2.1Km")
                SummaryComponent(title: "최고속도", content: "18Km/h")
                SummaryComponent(title: "스프린트 횟수", content: "6 times")
                SummaryComponent(title: "칼로리", content: "200 Kcal")
                
                Button(action: { dismiss() }) {
                    Text("완료")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.zone2Bpm)
                }
            }
        }
        
    }
}

#Preview {
    SummaryView()
}
