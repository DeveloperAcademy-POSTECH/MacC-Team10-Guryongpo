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
    @State var isLocationNotValid: Bool = false
    
    var body: some View {
        VStack {
            if !workoutManager.showingPrecount {
                ZStack {
                    Image("backgroundGlow")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    if !isHealthKitNotValid && !isLocationNotValid {
                        Button(action: { workoutManager.showingPrecount.toggle()}) {
                            Image(.startButton)
                        }
                    } else if isHealthKitNotValid{
                            Text("원활한 앱 사용을 위해\n\n아이폰의 건강 앱에서 SoccerBeat의 헬스킷 권한을 허용한 후 재실행 해주세요.\n\n공유 - 앱 및 서비스 - SoccerBeat - 모두 켜기")
                                .bold()
                                .padding()
                    } else if isLocationNotValid {
                        Text("원활한 앱 사용을 위해\n\n아이폰의 설정 앱에서 SoccerBeat의 위치 권한을 허용한 후 재실행 해주세요.\n\n설정 - 개인정보 보호 및 보안 - 위치 서비스 - SoccerBeat - 항상")
                            .bold()
                            .padding()
                    }
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
        .onReceive(workoutManager.authLocation, perform: {
            isLocationNotValid = true
        })
        .buttonStyle(.borderless)
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()
    
    return StartView()
        .environmentObject(workoutManager)
}
