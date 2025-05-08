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

    var body: some View {
        ZStack {
            Image("BackgroundPattern")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .opacity(0.5)
            
            TabView {
                
                FieldChartView(workout: workout)
                
                FieldMovementView(workout: workout)
            
                FieldRecordView(workout: workout)

            }
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
            .foregroundStyle(Color.white)
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
                .frame(width: 304, height: 290)
                .padding(36)
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
            GeometryReader { proxy in
                
                VStack(alignment: .leading, spacing: 16) {
                            if let workout = workout {
                                let recent = DataConverter.toLevels(workout)
                                let average = DataConverter.toLevels(profileModel.averageAbility)
                                
                                ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent, error: workout.error))
                                    .scaleEffect(CGSize(width: 0.9, height: 0.9))
                                    .fixedSize()
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    
                            } else {
                                let blankRecent = DataConverter.toLevels(WorkoutData.blankExample)
                                let blankAverage = DataConverter.toLevels(WorkoutAverageData.blankAverage)
                                
                                ViewControllerContainer(RadarViewController(radarAverageValue: blankAverage, radarAtypicalValue: blankRecent, error: true))
                                    .scaleEffect(CGSize(width: 0.9, height: 0.9))
                                    .fixedSize()
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                            }
                
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
                }
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
                        
                        HStack {
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
    private let emptyDataRoute: [CLLocationCoordinate2D] = []
    private let emptyDataCenter: [Double] = [0, 0]
    
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
                            
                            Button {
                                showShareView.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(.brightmint)
                            }
                            .font(.system(size: 18))
                            .padding(.bottom, 10)
                            .padding(.trailing, 4)
                            .sheet(isPresented: $showShareView) {
                                ShareMatchView(workout: workout ?? .example)
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
                
                GeometryReader { proxy in
                    
                    if let workout = workout {
                        if !workout.error {
                            if mapType == 0 {
                                HeatmapView(workout: WorkoutData.blankExample)
                                    .frame(height: proxy.size.height-40)
                                    .cornerRadius(15.0)
                            } else {
                                VStack(spacing: 0) {
                                    LocationView(slider: $slider, centerCoordinate: CLLocationCoordinate2D(latitude: workout.center[0], longitude: workout.center[1]), routes: workout.route)
                                        .frame(height: proxy.size.height - 60)
                                        .cornerRadius(15.0)
                                    
                                    Slider(
                                        value: $slider,
                                        in: 0...1
                                    )
                                    .padding(.vertical)
                                    .frame(height: 50)
                                }
                            }
                        } else {
                            if mapType == 0 {
                                HeatmapView(workout: WorkoutData.blankExample)
                                    .frame(height: proxy.size.height - 40)
                                    .cornerRadius(15.0)
                            } else {
                                LocationView(slider: $slider, centerCoordinate: CLLocationCoordinate2D(latitude: emptyDataCenter[0], longitude: emptyDataCenter[1]), routes: emptyDataRoute)
                                    .frame(height: proxy.size.height - 40)
                                    .cornerRadius(15.0)
                            }
                        }
                    }
                }
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
                                Text(workout.error ? "--" : workout.distance.formatted())
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
                                Text(workout.error ? "--" : workout.sprint.formatted())
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
                                Text(workout.error ? "--" : workout.minHeartRate.formatted())
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
                                Text(workout.error ? "--" : workout.velocity.formatted())
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
                        Text("파워")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            if let workout = workout {
                                Text(workout.error ? "--" : workout.power.rounded(at: 1)).font(.fieldRecordMeasure)
                            }  else {
                                Text("--")                                    .font(.fieldRecordMeasure)
                            }
                            Text(" w")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("최대 심박수")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            if let workout = workout {
                                Text(workout.error ? "--" : workout.maxHeartRate.formatted())
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
//            .padding(.vertical, 56)
            .padding(.horizontal, 20)
        }
        .kerning(-0.41)
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

struct FieldChartView: View {
    var workout: WorkoutData?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                InformationButton(message: "경기의 상세 데이터에 따라 뱃지가 수여됩니다.")
                Spacer()
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: -8) {
                    Text("Field Chart")
                }
                .font(.matchDetailTitle)
                Spacer()
            }
                        
            if let error = workout?.error {
                if error {
                    ErrorView(workout: workout) }
                else {
                    PlayerAbilityView(workout: workout)
                        .zIndex(-1.0)
                }
            }
            
            VStack {
                if let rates = workout?.heartRates {
                    if !rates.isEmpty {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                VStack(alignment: .leading, spacing: -8) {
                                    Text("Heartbeat")
                                        .opacity(0.7)
                                }
                                .font(.matchDetailSubTitle)
                            }
                            Spacer()
                        }
                        GeometryReader { proxy in
                        
                        HeartRatesView(rates: rates)
                            .frame(height: proxy.size.height - 30)
                            .padding()
                        }
                    }
                }
            }
            .padding(.bottom)
            Spacer()
        }
    }
}
