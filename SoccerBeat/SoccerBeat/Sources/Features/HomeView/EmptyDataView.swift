//
//  EmptyDataView.swift
//  SoccerBeat
//
//  Created by daaan on 11/20/23.
//

import SwiftUI

struct EmptyDataView: View {
    @State var workoutAverageData: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0, minHeartRate: 0, rangeHeartRate: 0, totalDistance: 0, maxAcceleration: 0, maxVelocity: 0, sprintCount: 0, totalMatchTime: 0)
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var profileModel: ProfileModel
    
    @State var isShowingBug = false
    let alertTitle = "문제가 있으신가요?"
    
    var body: some View {
            VStack(spacing: 0.0) {
                
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
                            .stroke(lineWidth: 0.8)
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
                        Text("----.--.--")
                            .font(.mainSubTitleText)
                            .opacity(0.7)
                        Text("최근 경기")
                            .font(.mainTitleText)
                    }
                    Spacer()
                    NavigationLink {
                        ProfileView()
                    } label: {
                        CardFront(degree: .constant(0), width: 72, height: 96)
                    }
                }
                .padding()
                
                LightRectangleView(alpha: 0.6, color: .black, radius: 15.0)
                    .frame(height: 234)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        VStack(alignment: .center) {
                            Text("저장된 경기 기록이 없습니다.")
                                .font(.mainSubTitleText)
                                .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding()
                            
                            Text("앱 사용을 위해 헬스 정보 접근 권한이 필요합니다.")
                                .font(.custom("NotoSans-Regular", size: 14))
                            HStack {
                                Button("위치 권한 설정하기") {
                                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(BUNDLE_IDENTIFIER)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                    
                                }
                                .buttonStyle(BorderedButtonStyle())
                                
                                Button("건강 권한 설정하기") {
                                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=HEALTH/\(BUNDLE_IDENTIFIER)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }                            
                        }
                    }
                
                Spacer()
                    .frame(height: 60)
                
                VStack(alignment: .leading) {
                    InformationButton(message: "최근 경기 데이터의 변화를 확인해 보세요.")
                    
                    HStack {
                        Text("추세")
                            .font(.mainTitleText)
                        Spacer()
                    }
                    .padding()
                }

                LightRectangleView(alpha: 0.15, color: .black, radius: 15.0)
                    .frame(height: 90)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Text("저장된 경기 기록이 없습니다.")
                            .font(.mainSubTitleText)
                            .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                
                Spacer()
            }
        .padding(.horizontal)
        .navigationTitle("")
    }
    
    private func openSettings(urlString: String) {
        guard let url = URL(string: urlString) else {
            NSLog("잘못된 URL입니다.: \(#function), URL: \(urlString)")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
    
    return EmptyDataView()
        .environmentObject(health)
        .environmentObject(sound)
        .environmentObject(profileModel)
}
