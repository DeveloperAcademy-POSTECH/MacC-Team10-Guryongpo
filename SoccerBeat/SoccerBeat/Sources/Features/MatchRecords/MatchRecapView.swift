//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchRecapView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @State private var userName = ""
    @Binding var workouts: [WorkoutData]
    
    private var lastName: String {
        guard let lastName = userName
            .split(separator: " ")
            .compactMap({ String($0) }).last else { return "" }
        return lastName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                InformationButton(message: "모든 경기를 한 눈에 확인해 보세요.")
                    .padding(.leading, 16)
                
                Spacer()
            }
            HStack {
                Text("경기 기록")
                    .font(.mainSubTitleText)
                    .foregroundStyle(.mainSubTitleColor)
                
                Spacer()
            }
            .padding(.top, 14)
            .padding(.leading, 32)
            
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    // view
                    Text("Player \(lastName),")
                        .lineLimit(1)
                    Text("Your past games")
                }
                .font(.mainTitleText)
                .foregroundStyle(.white)
                .kerning(-1.5)
                Spacer()
            }
            .padding(.leading, 32)
            .padding(.bottom, 45)
            
            if !workouts.isEmpty {
                List {
                    ForEach(workouts) { workout in
                        ZStack {
                            NavigationLink {
                                MatchDetailView(workout: workout)
                                    .toolbarRole(.editor)
                            } label: {
                                EmptyView()
                            }
                            .opacity(0.0)
                            
                            MatchListItemView(workoutData: workout)
                                .buttonStyle(.plain)
                        }
                        .offset(y: 4)
                        .padding(.vertical, 2)
                        .listRowSeparator(.hidden)
                    }
                    
                    .onDelete { offset in
                        Task {
                            await delete(offset)
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                ZStack {
                    Image("MyCardBack")
                        .resizable()
                        .frame(width: 107, height: 140)
                        .opacity(0.3)
                    VStack {
                        Text("저장된 경기 기록이 없습니다.")
                        .font(.matchRecapEmptyDataTop)
                        Group {
                            Text("애플워치를 차고 사커비트로")
                            Text("당신의 첫 번째 경기를 기록해 보세요!")
                        }
                        .font(.matchRecapEmptyDataBottom)
                        .foregroundStyle(.mainSubTitleColor)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
    
    private func delete(_ offset: IndexSet) async {
        workouts.remove(atOffsets: offset)
        do {
            try await healthInteractor.delete(at: offset)
        } catch {
            NSLog("Deleting HKWorkout failed")
        }
    }
}

struct MatchListItemView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @State private var currentLocation = "--'--"
    let workoutData: WorkoutData
    
    var body: some View {
        ZStack {
            // 배경뷰
            LightRectangleView(alpha: 0.2, color: .white, radius: 15)
            
            // 좌상단 뱃지뷰
            VStack {
                HStack(spacing: 0) {
                    badges
                        .offset(y: -12)
                    Spacer()
                    errors
                        .offset(x: -4, y: -8)
                }
                Spacer()
            }
            
            HStack(spacing: 0) {
                // 스파이더 차트
                radarCharts
//                    .frame(width: 60, height: 60)
                    .padding(.top, 16)
                    .opacity(workoutData.error ? 0 : 1)
                
                // 경기 데이터들
                VStack(alignment: .leading) {
                    timeAndLocation
                        .padding(.top, 3)
                    
                    Spacer()
                    
                    matchMatrics
                }
                .padding(.vertical, 8)
                .frame(width: 225)
                .foregroundStyle(.white)
            }
        }
    }
}

extension MatchListItemView {
    @ViewBuilder
    var badges: some View {
        if !workoutData.error {
            ForEach(workoutData.matchBadge.indices, id: \.self) { index in
                if let badgeName = ShortenedBadgeImageDictionary[index][workoutData.matchBadge[index]] {
                    if badgeName.isEmpty {
                        EmptyView()
                    } else {
                        Image(badgeName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 36)
                    }
                } else {
                    EmptyView()
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var errors: some View {
        if workoutData.error {
            Image(.errormark)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var radarCharts: some View {
        let recent = DataConverter.toLevels(workoutData)
        let average = DataConverter.toLevels(profileModel.averageAbility)
        
        RadarChartView(averageDataPoints: recent, limitValue: 5.0)

    }
    
    @ViewBuilder
    var timeAndLocation: some View {
        Group {
            Text(workoutData.yearMonthDay.description + " - " + currentLocation)
                .task {
                    currentLocation = await workoutData.location
                }
            HStack(spacing: 0) {
                Text("경기 시간 ")
                Text(workoutData.time)
            }
            
        }
        .opacity(0.6)
        .font(.matchDateLocationText)
    }
    
    @ViewBuilder
    var matchMatrics: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("뛴 거리")
                HStack(spacing: 0) {
                    Text((workoutData.error ? "--" : String(format: "%.1f", workoutData.distance)))
                    Text(" km")
                }
                .bold()
            }
            
            VStack(alignment: .leading) {
                Text("최고 속도")
                HStack(spacing: 0) {
                    Text((workoutData.error ? "--" :  "\(Int(workoutData.velocity).formatted())"))
                    Text(" km/h")
                }
                .bold()
            }
            
            VStack(alignment: .leading) {
                Text("스프린트")
                HStack(spacing: 0) {
                    if workoutData.sprint == 1 {
                        Text((workoutData.error ? "--" : "\(workoutData.sprint)"))
                        Text(" time")
                    } else {
                        Text((workoutData.error ? "--" : "\(workoutData.sprint)"))
                        Text(" times")
                    }
                }
                
                .bold()
            }
        }
        .padding(.vertical, 8)
        .font(.system(size: 14))
    }
}

#Preview {
    MatchRecapView(workouts: .constant(WorkoutData.exampleWorkouts))
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
        .environmentObject(HealthInteractor())
}
