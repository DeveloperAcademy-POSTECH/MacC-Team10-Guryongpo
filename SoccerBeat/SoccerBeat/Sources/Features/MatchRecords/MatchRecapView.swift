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
    @Binding var userWorkouts: [WorkoutData]
    
    private var lastName: String {
        guard let lastName = userName
            .split(separator: " ")
            .compactMap({ String($0) }).last else { return "" }
        return lastName
    }

    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 56)
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
            
            List {
                ForEach(userWorkouts) { workout in
                    ZStack {
                        NavigationLink {
                            MatchDetailView(workoutData: workout)
                                .toolbarRole(.editor)
                        } label: {
                            EmptyView()
                        }
                        .opacity(0.0)
                        
                        MatchListItemView(workoutData: workout)
                            .buttonStyle(.plain)
                    }
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
        }
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
    
    private func delete(_ offset: IndexSet) async {
        userWorkouts.remove(atOffsets: offset)
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
                }
                Spacer()
            }
            
            HStack(spacing: 0) {
                // 스파이더 차트
                radarCharts
                    .padding(.top, 16)
                
                // 경기 데이터들
                VStack(alignment: .leading) {
                    timeAndLocation
                    
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
    }
    
    @ViewBuilder
    var radarCharts: some View {
        let recent = DataConverter.toLevels(workoutData)
        let average = DataConverter.toLevels(profileModel.averageAbility)
        
        RadarChartView(averageDataPoints: recent, maximumDataPoints: average, limitValue: 2.5)
    }
    
    @ViewBuilder
    var timeAndLocation: some View {
        Group {
            Text(workoutData.yearMonthDay.description + " - " + currentLocation)
                .task {
                    currentLocation = await workoutData.location
                }
            HStack(spacing: 0) {
                Text("경기 시간")
                Text(" " + workoutData.time)
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
                Text(String(format: "%.1f", workoutData.distance) + "km")
                    .bold()
            }
            
            VStack(alignment: .leading) {
                Text("최고 속도")
                Text("\(Int(workoutData.velocity).formatted()) km/h")
                    .bold()
            }
            
            VStack(alignment: .leading) {
                Text("스프린트")
                HStack(spacing: 0) {
                    Text("\(workoutData.sprint) ")
                    Text("회")
                }
                
                    .bold()
            }
        }
        .padding(.vertical, 8)
        .font(.system(size: 14))
    }
}

#Preview {
    MatchRecapView(userWorkouts: .constant(WorkoutData.exampleWorkouts))
}
