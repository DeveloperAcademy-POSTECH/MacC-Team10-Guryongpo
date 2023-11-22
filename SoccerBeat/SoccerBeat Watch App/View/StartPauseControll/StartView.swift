//
//  StartView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State var isHealthKitNotValid: Bool = false
    @State var isShowingAlert: Bool = false
    
    var body: some View {
        VStack {
            if !workoutManager.showingPrecount {
                ZStack {
                    Image("backgroundGlow")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    if !isHealthKitNotValid {
                        Button(action: {
                            if workoutManager.locationManager.authorizationStatus == .denied ||
                                workoutManager.locationManager.authorizationStatus == .notDetermined
                            {
                                isShowingAlert.toggle()
                            } else {
                                workoutManager.showingPrecount.toggle()
                            }
                        }) {
                            Image(.startButton)
                        }
                    } else if isHealthKitNotValid{
                            Text("원활한 앱 사용을 위해\n\n아이폰의 건강 앱에서 SoccerBeat의 헬스킷 권한을 허용한 후 재실행 해주세요.\n\n공유 - 앱 및 서비스 - SoccerBeat - 모두 켜기")
                                .bold()
                                .padding()
                    }
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                                title: Text("위치 권한이 허용되지 않았습니다."),
                                message: Text("원활한 앱 사용을 위해\n\n아이폰의 설정 앱에서 SoccerBeat의 위치 권한을 허용한 후 재실행 해주세요."),
                                dismissButton: .destructive(Text("확인"))
                            )
                }
            } else {
                PrecountView()
            }
        }
        .task {
            workoutManager.requestAuthorization()
        }
        .onReceive(workoutManager.authHealthKit, perform: {
            isHealthKitNotValid = true
        })
        .buttonStyle(.borderless)
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()
    
    return StartView()
        .environmentObject(workoutManager)
}
