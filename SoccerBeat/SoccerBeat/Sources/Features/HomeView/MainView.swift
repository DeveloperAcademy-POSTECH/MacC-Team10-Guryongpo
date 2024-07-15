//
//  MainView.swift
//  SoccerBeat
//
//  Created by daaan on 11/16/23.
//

import SwiftUI

struct MainView: View {
    @State private var isShowingOnboardingView = true

    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    @State private var isFlipped = false
    @State private var currentLocation = "---"
    @Binding var workouts: [WorkoutData]
    
    @State var isShowingBug = false
    private let alertTitle = "문제가 있으신가요?"
    private let emptyDataMessage = "저장된 경기 기록이 없습니다."
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
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
                    Spacer()
                    
                    Button(action: { isShowingBug.toggle() } ) {
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
                            // Handle the acknowledgement.
                            isShowingBug.toggle()
                        }
                        Button("문의하기") {
                            let url = createEmailUrl(to: "guryongpo23@gmail.com", subject: "", body: "")
                            openURL(urlString: url)
                            // TODO: 로그인 안될 때엔 어떻게 됩니까?
                        }
                    } message: {
                        Text("불편을 드려 죄송합니다. \n\nSoccerBeat의 개발자 계정으로 문의를 주시면 빠른 시일 안에 답변드리겠습니다. ")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        if !workouts.isEmpty {
                            Text(workouts[0].yearMonthDay)
                                .font(.mainSubTitleText)
                                .opacity(0.7)
                        } else {
                            Text("----.--.--")
                                .font(.mainSubTitleText)
                                .opacity(0.7)
                        }
                        Text("최근 경기")
                            .font(.mainTitleText)
                    }
                    
                    
                    Spacer()
                    NavigationLink {
                        ProfileView()
                    } label: {
                        CardFront(degree: .constant(0), width: 72, height: 110)
                    }
                }
                .padding()
                
                if !workouts.isEmpty {
                    NavigationLink {
                        MatchDetailView(workoutData: workouts[0])
                    } label: {
                        ZStack {
                            LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                            HStack {
                                VStack {
                                    HStack {
                                        let recent = DataConverter.toLevels(workouts[0])
                                        let average = DataConverter.toLevels(profileModel.averageAbility)
                                        
                                        ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent)).scaleEffect(CGSize(width: 0.6, height: 0.6))
                                            .padding()
                                            .fixedSize()
                                            .frame(width: 220, height: 210)
                                        Spacer()
                                        
                                        // 최근 경기 미리보기 오른쪽
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
                                                    
                                                    if !workouts.isEmpty {
                                                        Text(workouts[0].time)
                                                    }
                                                }
                                                .font(.mainTime)
                                                .foregroundStyle(.mainMatchTime)
                                            }
                                            
                                            Spacer()
                                            
                                            // 뱃지
                                            HStack {
                                                if !workouts.isEmpty {
                                                    ForEach(workouts[0].matchBadge.indices, id: \.self) { index in
                                                        if let badgeName = ShortenedBadgeImageDictionary[index][workouts[0].matchBadge[index]] {
                                                            if badgeName.isEmpty {
                                                                EmptyView()
                                                            } else {
                                                                Image(badgeName)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fit)
                                                                    .frame(width: 32, height: 36)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                } else {
                    ZStack {
                        LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                            .frame(height: 234)
                            .foregroundStyle(.white.opacity(0.1))
                        
                        VStack(spacing: nil) {
                            highlightedInfomationalText(emptyDataMessage)
                                .padding(.top, 46)
                            
                            Text("애플워치를 차고 당신의 첫 번째 경기를 기록해 보세요!")
                                .font(.notoSans(size: 14))
                                .foregroundStyle(.subInfomational)
                                .padding(.top, 20)
                        }
                    }
                }
                
                if !workouts.isEmpty {
                    NavigationLink {
                        MatchRecapView(userWorkouts: $workouts)
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
                
                Spacer()
                    .frame(height: 80)
                
                if !workouts.isEmpty {
                    AnalyticsView()
                } else {
                    VStack(alignment: .leading) {
                        
                        InformationButton(message: "최근 경기 데이터의 변화를 확인해 보세요.")
                        
                        HStack {
                            Text("추세")
                                .font(.mainTitleText)
                            Spacer()
                        }
                        .padding()
                    }
                    ZStack {
                        LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                            .frame(height: 91)
                        
                        VStack(spacing: nil) {
                            highlightedInfomationalText(emptyDataMessage)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingOnboardingView) {
            OnboardingView()
                .presentationDetents([.medium])
        }
        .onAppear {
            isShowingOnboardingView = workouts.isEmpty
        }
        .onChange(of: workouts) { newValue in
            isShowingOnboardingView = newValue.isEmpty
        }
        .refreshable {
            await healthInteractor.fetchWorkoutData()
        }
        .padding(.horizontal)
        .navigationTitle("")
    }
    
    private func highlightedInfomationalText(_ message: String) -> some View {
        Text(LocalizedStringKey(emptyDataMessage))
            .font(.summaryContent)
            .foregroundStyle(.playTimeNumber)
    }
    
    func openURL(urlString: String){
        if let url = URL(string: "\(urlString)"){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url)
            }
            else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let defaultUrl = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        return defaultUrl
    }
    
}

#Preview {
    @StateObject var health = HealthInteractor.shared
    @StateObject var sound = SoundManager()
    @StateObject var profileModel = ProfileModel(healthInteractor: .shared)
    @State var workouts = WorkoutData.exampleWorkouts
    
    return MainView(workouts: $workouts)
        .environmentObject(health)
        .environmentObject(sound)
        .environmentObject(profileModel)
}
