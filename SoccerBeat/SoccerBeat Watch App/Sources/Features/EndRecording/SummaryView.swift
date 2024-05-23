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
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    @State private var isShowingSummary = false
    
    var body: some View {
        if isShowingSummary {
            ScrollView(showsIndicators: false) {
                SummaryComponent(title: "뛴 거리",
                                 content: (matricsIndicator.distanceMeter / 1000).rounded(at: 2) + " km")
                SummaryComponent(title: "최고 속도", content: (matricsIndicator.maxSpeedMPS * 3.6).rounded(at: 1) + " km/h")
                SummaryComponent(title: "스프린트 횟수", content:  matricsIndicator.sprintCount.formatted() + " Times")
                
                SummaryComponent(title: "파워", content:  matricsIndicator.power.rounded(at: 1) + " w")

                Button {
                    dismiss()
                } label: {
                    Text("완료")
                        .font(.summaryDoneButton)
                        .foregroundStyle(.summaryGradient)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
        } else {
            PhraseView()
                .navigationBarHidden(true)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 ) {
                        withAnimation {
                            isShowingSummary.toggle()
                        }
                    }
                }
        }
    }
}

#Preview {
    SummaryView()
}
