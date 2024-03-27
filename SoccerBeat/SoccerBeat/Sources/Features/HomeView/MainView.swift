//
//  MainView.swift
//  SoccerBeat
//
//  Created by daaan on 11/16/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var viewModel: ProfileModel
    @State private var isFlipped = false
    @State private var currentLocation = "---"
    @Binding var workouts: [WorkoutData]
    
    @State var isShowingBug = false
    let alertTitle: String = "문제가 있으신가요?"
    
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
                    .padding(.top, 5)
                    Spacer()
                    
                    Button(action: { isShowingBug.toggle() } ) {
                        Image(systemName: "ant")
                            .foregroundStyle(.white)
                            .font(.mainInfoText)
                            .padding()
                    }
                    .overlay {
                        Capsule()
                            .stroke()
                            .frame(height: 24)
                    }
                    .padding(.horizontal)
                    .alert(
                                alertTitle,
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
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(workouts[0].yearMonthDay)
                            .font(.mainSubTitleText)
                            .opacity(0.7)
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
                                    
                                    ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))                              .scaleEffect(CGSize(width: 0.7, height: 0.7))
                                        .fixedSize()
                                        .frame(width: 210, height: 210)
                                    
                                    Spacer()
                                    
                                    // 최근 경기 미리보기 오른쪽
                                    VStack(alignment: .trailing) {
                                        
                                        VStack(alignment: .leading) {
                                            Text(currentLocation)
                                                .font(.mainDateLocation)
                                                .foregroundStyle(.mainDateTime)
                                                .opacity(0.8)
                                                .task {
                                                    currentLocation = await workouts[0].location
                                                }
                                            Group {
                                                Text("경기 시간")
                                                Text(workouts[0].time)
                                            }
                                            .font(.mainTime)
                                            .foregroundStyle(.mainMatchTime)
                                        }
                                        
                                        Spacer()
                                        
                                        // 뱃지
                                        HStack {
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
                            Spacer()
                        }
                        .padding()
                    }
                }
                
                NavigationLink {
                    ScrollView(showsIndicators: false) {
                        MatchRecapView(userWorkouts: workouts)
                    }
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
                
                Spacer()
                    .frame(height: 80)
                
                AnalyticsView()
            }
            .onAppear {
                if !soundManager.isMusicPlaying {
                    soundManager.toggleMusic()
                }
            }
        }
        .refreshable {
            healthInteractor.requestAuthorization()
        }
        .onReceive(healthInteractor.authSuccess, perform: {
            Task {
                print("ContentView: attempting to fetch all data..")
                await healthInteractor.fetchWorkoutData()
            }
        })
        
        .padding(.horizontal)
        .navigationTitle("")
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
