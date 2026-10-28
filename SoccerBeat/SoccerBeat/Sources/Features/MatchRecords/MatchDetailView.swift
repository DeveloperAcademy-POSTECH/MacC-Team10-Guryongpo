//
//  MatchDetailView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI
import Charts
import CoreLocation

struct MatchDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var workout: WorkoutData?
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var refreshedWorkout: WorkoutData?
    @State private var selectedPage = 0

    private var currentWorkout: WorkoutData? {
        refreshedWorkout?.id == workout?.id ? (refreshedWorkout ?? workout) : workout
    }

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $selectedPage) {
                FieldChartView(workout: currentWorkout)
                    .tag(0)
                FieldMovementView(workout: currentWorkout)
                    .tag(1)
                FieldRecordView(workout: currentWorkout)
                    .tag(2)
            }
            .overlay(alignment: .topTrailing) {
                if workoutManager.isLoading {
                    ProgressView()
                        .tint(.white)
                        .accessibilityLabel("경기 기록을 불러오는 중입니다.")
                        .padding(4)
                        .allowsHitTesting(false)
                }
            }
        }
        .onReceive(workoutManager.fetchWorkoutsSuccess) { records in
            if let id = workout?.id, let updated = records.first(where: { $0.id == id }) {
                refreshedWorkout = updated
            }
        }
        .task(id: workout?.id) { await workoutManager.fetchWorkoutData() }
        .padding()
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .padding(.bottom, selectedPage == 0 ? 0 : 32)
        .foregroundStyle(Color.white)
        .background {
            // Keep the full-screen background from expanding content into the navigation bar.
            GeometryReader { proxy in
                Image("BackgroundPattern")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .opacity(0.5)
            }
            .ignoresSafeArea()
        }
    }
}

struct ErrorView: View {
    var workout: WorkoutData?
    
    var body: some View {
        if let workout = workout {
            if !workout.error {
                EmptyView()
            } else {
                VStack {
                    Image(.errormark)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 74, height: 80)
                        .padding()
                    Text("데이터에 오류가 발생했습니다. ")
                        .font(.averageValue)
                        .foregroundStyle(.white)
                        .padding(2)
                    Text("건강 및 위치 권한을 재확인하거나\n삭제 및 재설치를 권장드립니다.")
                }
                .font(.fieldRecordTitle)
                .foregroundStyle(.mainSubTitleColor)
                .fixedSize()
                .frame(width: 300, height: 290)
                .padding(.vertical, 36)
            }
        } else {
            EmptyView()
        }
    }
}

struct MatchTimeView: View {
    var workout: WorkoutData?
    
    var body: some View {
        VStack(alignment: .leading) {

            VStack(alignment: .leading, spacing: -8) {
                HStack(spacing: 0) {
                    Text("경기 시간")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if let workout = workout {
                        Text(" \(workout.time)")
                    } else {
                        Text(" --:--")
                    }
                }
            }
            .font(.matchDetailTitle)
        }
    }
}

struct PlayerAbilityView: View {
    @EnvironmentObject var profileModel: ProfileModel
    var workout: WorkoutData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let recent = DataConverter.toLevels(workout ?? WorkoutData.blankExample)
            let average = DataConverter.toLevels(workout == nil ? WorkoutAverageData.blankAverage : profileModel.averageAbility)

            ViewControllerContainer(RadarViewController(radarAverageValue: average,
                                                       radarAtypicalValue: recent,
                                                       error: workout?.error ?? true))
                .id([recent, average])
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text("빨간색")
                        .bold()
                        .foregroundStyle(.matchDetailViewTitleColor)
                    Text("은 경기의 평균 능력치입니다.")
                }
                .floatingCapsuleStyle()

                HStack(spacing: 0) {
                    Text("민트색")
                        .bold()
                        .foregroundStyle(.matchDetailViewAverageStatColor)
                    Text("은 이번 경기의 능력치입니다.")
                }
                .floatingCapsuleStyle()
            }
            .font(.caption)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FieldRecordView: View {
    var workout: WorkoutData?
    @State var isInfoOpen: Bool = false
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    InformationButton(message: "경기의 상세 데이터에 따라 뱃지가 수여됩니다.")
                    Spacer()
                }
                .zIndex(4.0)
                
                HStack {
                    VStack(alignment: .leading, spacing: -8) {
                        Text("Field Record")
                    }
                    .font(.matchDetailTitle)
                    Spacer()
                }
                
                Spacer()
                
                ZStack {
                    LightRectangleView(alpha: 0.4, color: .black, radius: 15)
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .center) {
                                VStack(alignment: .center, spacing: -8) {
                                    Text("Today's Badge")
                                }
                                .font(.matchDetailTitle)
                                .scaleEffect(0.8)
                                .opacity(0.5)
                            }
                        }
                        .padding(.top)
                        
                        HStack(alignment: .bottom) {
                            if let workout = workout {
                                if !workout.error {
                                    ForEach(workout.matchBadge.indices, id: \.self) { index in
                                        if let badgeName = BadgeImageDictionary[index][workout.matchBadge[index]] {
                                            if badgeName.isEmpty {
                                                Image(.errormark)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 64, height: 72)
                                                    .padding()
                                                    .padding(.bottom, 10)
                                                    .opacity(0.7)
                                                
                                            } else {
                                                Image(badgeName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 74, height: 82)
                                                    .padding()
                                            }
                                        } else {
                                            Image(.errormark)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 64, height: 72)
                                                .padding()
                                                .padding(.bottom, 10)
                                                .opacity(0.7)
                                        }
                                    }
                                } else {
                                    Image(.errormark)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 64, height: 72)
                                        .padding()
                                        .padding(.bottom, 10)
                                        .opacity(0.7)
                                }
                            } else {
                                Image(.errormark)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 64, height: 72)
                                    .padding()
                                    .padding(.bottom, 10)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .frame(height: proxy.size.height / 3.5)
                
                Spacer()
                
                FieldRecordDataView(workout: workout)
                    .padding(.bottom, 40)
                
                Spacer()
            }
        }
    }
}

struct FieldMovementView: View {
    var workout: WorkoutData?
    @State var isInfoOpen: Bool = false
    @State private var slider = 0.0
    @State private var showShareView = false
    @State private var mapType = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        InformationButton(message: "슬라이더를 움직여 경기 중 위치를 확인해보세요.")
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        
                        HStack(alignment: .bottom) {
                            Text("Field Movement")
                                .font(.matchDetailTitle)
                            Spacer()
                            
                            
                            if let error = workout?.error {
                                if !error { // not error
                                    Button {
                                        showShareView.toggle()
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundStyle(.brightmint)
                                    }
                                    .font(.system(size: 18))
                                    .padding(.bottom, 10)
                                    .padding(.trailing, 4)
                                    .disabled(workout?.route.isEmpty != false)
                                    .sheet(isPresented: $showShareView) {
                                        ShareMatchView(workout: workout ?? .example)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            VStack {
                Picker("Pick map type", selection: $mapType) {
                    Text("Heatmap").tag(0)
                    Text("Location").tag(1)
                }
                .pickerStyle(.segmented)
                
                let mapWorkout = workout.flatMap { $0.error ? nil : $0 } ?? .blankExample

                VStack(spacing: 16) {
                    Group {
                        if workout != nil, !mapWorkout.route.isEmpty {
                            if mapType == 0 {
                                HeatmapView(workout: mapWorkout)
                                    .cornerRadius(15.0)
                                    .id(mapWorkout)
                            } else {
                                LocationView(slider: $slider, workout: mapWorkout)
                                    .id(mapWorkout)
                            }
                        } else {
                            WorkoutDataNotice(title: "경로 데이터를 표시할 수 없습니다.",
                                              availability: workout?.routeAvailability ?? .unavailable)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FieldRecordDataView: View {
    var workout: WorkoutData?
    var body: some View {
        ZStack {
            LightRectangleView(alpha: 0.4, color: .black, radius: 15)
            
            HStack(alignment: .center, spacing: 50) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("뛴 거리")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.distance) ? "--" : workout.distance.formatted(.number.precision(.fractionLength(1))))
                                    .font(.fieldRecordMeasure)
                            } else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(" km")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("스프린트")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.sprint) ? "--" : workout.sprint.formatted())
                                    .font(.fieldRecordMeasure)
                            }  else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(" Times")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("최소 심박수")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.minHeartRate) ? "--" : workout.minHeartRate.formatted())
                                    .font(.fieldRecordMeasure)
                            } else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text("Bpm")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("최고 속도")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.maxSpeed) ? "--" : workout.velocity.formatted(.number.precision(.fractionLength(0...2))))
                                    .font(.fieldRecordMeasure)
                            } else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(" km/h")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("칼로리")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.calories) ? "--" : workout.calories.formatted()).font(.fieldRecordMeasure)
                            }  else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(verbatim: " kcal")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("최대 심박수")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            if let workout = workout {
                                Text(workout.error || workout.unavailableMetrics.contains(.maxHeartRate) ? "--" : workout.maxHeartRate.formatted())
                                    .font(.fieldRecordMeasure)
                            } else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(" Bpm")
                                .font(.fieldRecordUnit)
                        }
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
        .kerning(-0.41)
    }
}

struct FieldChartView: View {
    var workout: WorkoutData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                FieldChartInformationButton(workout: workout)
                Spacer()
            }

            Text("Field Chart")
                .font(.matchDetailTitle)

            GeometryReader { proxy in
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        if workout?.error == true {
                            ErrorView(workout: workout)
                        } else {
                            PlayerAbilityView(workout: workout)
                        }
                    }
                    .frame(height: proxy.size.height * 0.60)

                    Text("Heartbeat")
                        .font(.matchDetailSubTitle)
                        .opacity(0.7)

                    Group {
                        if let workout, !workout.heartRates.isEmpty {
                            HeartRatesView(rates: workout.heartRates, dates: workout.heartRateDates)
                                .padding(.horizontal, 8)
                                .padding(.top, 6)
                        } else {
                            WorkoutDataNotice(title: "심박 기록을 표시할 수 없습니다.",
                                              availability: workout?.heartRateAvailability ?? .unavailable)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .padding(.bottom, 28)
    }
}

private struct WorkoutDataNotice: View {
    let title: LocalizedStringKey
    let availability: WorkoutDataAvailability

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
            Text(title)
                .font(.headline)
            switch availability {
            case .pending:
                Text("기록이 동기화되면 다시 표시됩니다.")
            case .failed:
                Text("데이터 조회에 실패했습니다. 다시 불러오기를 시도해 주세요.")
            case .permissionDenied:
                Text("건강 데이터 접근 권한을 확인해 주세요.")
            case .available, .unavailable:
                Text("데이터가 아직 없거나 접근이 제한되었을 수 있습니다. 건강 앱에서 기록과 권한을 확인해 주세요.")
            }
        }
        .font(.caption)
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager.shared
    return NavigationView {
        MatchDetailView(workout: WorkoutData.example)
            .environmentObject(ProfileModel(workoutManager: workoutManager))
            .environmentObject(workoutManager)
    }
}

struct FieldChartInformationButton: View {
    var workout: WorkoutData?
    @State private var isPresented = false
    private let titles = ["민첩성", "적극성", "잠재력", "정신력", "지구력", "폭발력"]
    private let details = ["chart.v2.agility", "chart.v2.activity", "chart.v2.potential",
                           "chart.v2.mentality", "chart.v2.endurance", "chart.v2.explosivity"]

    var body: some View {
        Button { isPresented = true } label: {
            Image(.infoIcon)
                .resizable()
                .frame(width: 11, height: 16)
                .floatingCapsuleStyle(color: .white.opacity(0.8))
        }
        .accessibilityLabel("chart.v2.title")
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        let scores = workout.map { DataConverter.measuredScores($0) }
                        Text("chart.v2.overview")
                        ForEach(0..<6) { index in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(LocalizedStringKey(titles[index])).font(.headline)
                                    Spacer()
                                    if let scores {
                                        Text(LocalizedStringKey(scores[index] == nil
                                                               ? "chart.v2.reference" : "chart.v2.measured"))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Text(LocalizedStringKey(details[index]))
                            }
                        }
                        Text("chart.v2.missing").font(.footnote).foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .navigationTitle("chart.v2.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("닫기") { isPresented = false } }
            }
        }
    }
}
