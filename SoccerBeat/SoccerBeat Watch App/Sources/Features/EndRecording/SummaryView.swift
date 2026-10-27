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
    @State private var selection: SummarySort = .sportsInfo
    @State var isBlinking = false
    @State var isHeartBlinking = false
    
    private enum SummarySort {
        case sportsInfo, heartInfo
    }
    
    var body: some View {
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
                            saveControls
                            
                        }
                        .onAppear {
                            withAnimation {
                                isHeartBlinking = true
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
    }

    @ViewBuilder
    private var saveControls: some View {
        VStack(spacing: 4) {
            switch workoutManager.workoutSaveState {
            case .saving:
                ProgressView("경기 기록을 저장하고 있어요.")
                    .font(.caption2)
            case .partial:
                Text("운동은 저장됐지만 일부 데이터의 저장 확인이 필요해요.")
                    .font(.caption2)
            case .failed:
                Text("운동 저장을 확인하지 못했어요. 다시 확인해 주세요.")
                    .font(.caption2)
            default:
                EmptyView()
            }
            if workoutManager.watchRecording != nil &&
                (workoutManager.workoutSaveState == .partial || workoutManager.workoutSaveState == .failed) {
                Button("저장 상태 다시 확인") { workoutManager.retryWorkoutSave() }
                    .font(.caption2)
            }
            if workoutManager.canDismissWorkoutSummary {
                Button {
                    workoutManager.showingSummaryView = false
                } label: {
                    Capsule()
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                        .foregroundStyle(Color.columnContent)
                        .overlay {
                            Text(LocalizedStringKey(workoutManager.workoutSaveState == .failed ? "닫기" : "완료"))
                                .font(.summaryDoneButton)
                                .foregroundStyle(.summaryGradient)
                        }
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 16)
    }

}

struct InfoSportsView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                SummaryComponent(title: "뛴 거리_",
                                 content: matricsIndicator.hasDistanceData ? (matricsIndicator.distanceMeter / 1000).rounded(at: 1) : "--", unit: "km")
                SummaryComponent(title: "최고 속도", content: matricsIndicator.hasSpeedData ? (matricsIndicator.maxSpeedMPS * 3.6).rounded(at: 0) : "--", unit: "km/h")
            }
            HStack(spacing: 4) {
                SummaryComponent(title: "스프린트", content: matricsIndicator.hasSpeedData ? matricsIndicator.sprintCount.formatted() : "--", unit: "Times")
                SummaryComponent(title: "칼로리", content: matricsIndicator.hasCaloriesData ? matricsIndicator.energy.rounded(at: 0) : "--", unit: "kcal")
            }
        }
    }
}

struct InfoHeartView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    var body: some View {
        HStack(spacing: 4) {
            SummaryComponent(title: "최소심박",
                             content: matricsIndicator.hasHeartRateData ? matricsIndicator.saveMinHeartRate.formatted() : "--", unit: "Bpm")
            SummaryComponent(title: "최대심박", content: matricsIndicator.hasHeartRateData ? matricsIndicator.saveMaxHeartRate.formatted() : "--", unit: "Bpm")
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(DIContianer.makeWorkoutManager())
        .environmentObject(DIContianer.makeMatricsIndicator())
}
