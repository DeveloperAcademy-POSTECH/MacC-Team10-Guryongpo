//
//  MainView.swift
//  SoccerBeat
//
//  Created by daaan on 11/16/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var isShowingOnboardingView: Bool
    @Binding var isShowingSessionView: Bool
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var soundManager: SoundManager
    @State private var isFlipped = false
    @State private var currentLocation = "---"
    @Binding var workouts: [WorkoutData]
    @State var timer: Timer?
    
    @State private var isShowingBug = false
    private let alertTitle = "문제가 있으신가요?"
    
    var body: some View {
        Image("BackgroundPattern")
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
            .overlay {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 50)
                        headerView
                        contentView
                        Spacer()
                            .frame(height: 80)
                        AnalyticsView(workouts: $workouts)
                    }
                }
                .sheet(isPresented: $isShowingOnboardingView) {
                    OnboardingView()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $isShowingSessionView) {
                    VStack {
                        RunningModalView()
                    }
                    .presentationDetents([.fraction(0.3)])
                    .presentationDragIndicator(.visible)
                }
                .refreshable {
                    await workoutManager.fetchWorkoutData()
                }
                .padding(.horizontal)
                .onAppear {
                    // 타이머 시작
                    startMonitoring()
                }
                .onDisappear {
                    timer?.invalidate()
                }
            }
    }
    
    private var headerView: some View {
        HStack {
            soundButton
            Spacer()
            bugButton
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    private var soundButton: some View {
        Button {
            soundManager.toggleMusic()
        } label: {
            HStack {
                Image(systemName: soundManager.isMusicPlaying ? "speaker" : "speaker.slash")
                Text(soundManager.isMusicPlaying ? "On" : "Off")
            }
            .padding(.horizontal)
            .font(.mainInfoText)
            .overlay {
                Capsule()
                    .stroke()
                    .frame(height: 24)
            }
        }
        .foregroundStyle(.white)
    }
    
    private var bugButton: some View {
        Button {
            isShowingBug.toggle()
        } label: {
            Image(systemName: "ant")
                .foregroundStyle(.white)
                .font(.mainInfoText)
                .padding()
        }
        .overlay {
            Capsule()
                .stroke(lineWidth: 0.8)
                .frame(height: 24)
        }
        .alert(
            LocalizedStringKey(alertTitle),
            isPresented: $isShowingBug
        ) {
            Button("취소", role: .cancel) {
                isShowingBug.toggle()
            }
            Button("문의하기") {
                let url = createEmailUrl(to: "guryongpo23@gmail.com", subject: "", body: "")
                openURL(urlString: url)
            }
        } message: {
            Text("불편을 드려 죄송합니다. \n\nSoccerBeat의 개발자 계정으로 문의를 주시면 빠른 시일 안에 답변드리겠습니다. ")
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            recentMatchHeaderView
            recentMatchPreview
            allMatchesLink
        }
    }
    
    private var recentMatchHeaderView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Group {
                    if !workouts.isEmpty {
                        Text(workouts[0].yearMonthDay)
                    } else {
                        Text("----.--.--")
                    }
                }
                .font(.mainSubTitleText)
                .opacity(0.7)
                Text("최근 경기")
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .font(.mainTitleText)
                    .padding(.trailing)
            }
            Spacer()
            NavigationLink {
                ProfileView()
            } label: {
                CardFront(degree: .constant(0), width: 72, height: 110)
            }
        }
        .padding()
    }
    
    private var recentMatchPreview: some View {
        NavigationLink {
            if workouts.isEmpty {
                MatchDetailView(workout: nil)
            } else {
                MatchDetailView(workout: workouts[0])
            }
        } label: {
            ZStack {
                LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                HStack {
                    VStack {
                        HStack {
                            if !workouts.isEmpty {
                                let recent = DataConverter.toLevels(workouts[0])
                                let average = DataConverter.toLevels(profileModel.averageAbility)
                                
                                ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent, error: workouts[0].error))
                                    .scaleEffect(CGSize(width: 0.6, height: 0.6))
                                    .padding()
                                    .fixedSize()
                                    .frame(width: 220, height: 210)
                            } else {
                                let blankRecent = DataConverter.toLevels(WorkoutData.blankExample)
                                let blankAverage = DataConverter.toLevels(WorkoutAverageData.blankAverage)
                                
                                ViewControllerContainer(RadarViewController(radarAverageValue: blankAverage, radarAtypicalValue: blankRecent, error: true))
                                    .scaleEffect(CGSize(width: 0.6, height: 0.6))
                                    .padding()
                                    .fixedSize()
                                    .frame(width: 220, height: 210)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                VStack(alignment: .leading) {
                                    Text(currentLocation)
                                        .font(.mainDateLocation)
                                        .foregroundStyle(.mainDateTime)
                                        .opacity(0.8)
                                        .task {
                                            if !workouts.isEmpty {
                                                currentLocation = await workouts[0].location
                                            }
                                        }
                                    Group {
                                        Text("경기 시간")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                        Group {
                                            if !workouts.isEmpty {
                                                Text(workouts[0].time)
                                            } else {
                                                Text("--:--")
                                            }
                                        }
                                    }
                                    .font(.mainTime)
                                    .foregroundStyle(.mainMatchTime)
                                }
                                Spacer()
                                if !workouts.isEmpty && !workouts[0].error {
                                    HStack {
                                        ForEach(workouts[0].matchBadge.indices, id: \.self) { index in
                                            let row = index
                                            let column = workouts[0].matchBadge[index]
                                            if let badgeName = ShortenedBadgeImageDictionary[row][column],
                                               !badgeName.isEmpty {
                                                Image(badgeName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 25, height: 35)
                                            }
                                        }
                                    }
                                } else if !workouts.isEmpty && workouts[0].error {
                                    Image(.errormark)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 35)
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private var allMatchesLink: some View {
        NavigationLink {
            MatchRecapView(workouts: $workouts)
        } label: {
            ZStack {
                LightRectangleView(alpha: 0.15, color: .seeAllMatch, radius: 22)
                    .frame(height: 38)
                HStack {
                    Spacer()
                    Image(systemName: "soccerball")
                    Text("모든 경기 보기 +")
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    func openURL(urlString: String) {
        if let url = URL(string: "\(urlString)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
    }
    
    func startMonitoring() {
        // 워치 세션 모니터링
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if !workoutManager.formerSession && workoutManager.session?.state == .running {
                self.isShowingSessionView = true
            }
            
            if workoutManager.formerSession && workoutManager.session?.state != .running {
                self.isShowingSessionView = false
            }
            
            // 앱 종료 / 백그라운드 이동 시 타이머 비활성화
            if scenePhase == .background {
                self.timer?.invalidate()
            }
            workoutManager.formerSession = workoutManager.session?.state == .running
        }
    }
}

#Preview {
    @StateObject var health = WorkoutManager.shared
    @StateObject var sound = SoundManager()
    @StateObject var profileModel = ProfileModel(workoutManager: .shared)
    @State var workouts = WorkoutData.exampleWorkouts
    @State var isShowingOnboardingView = false
    @State var isShowingSessionView: Bool = false
    
    return MainView(isShowingOnboardingView: $isShowingOnboardingView, isShowingSessionView: $isShowingSessionView, workouts: $workouts)
        .environmentObject(health)
        .environmentObject(sound)
        .environmentObject(profileModel)
}
