//
//  StartView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var isShowingAlert = false
    
    var body: some View {
        VStack {
            if !workoutManager.showingPrecount {
                ZStack {
                    Image(.backgroundGlow)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    Button {
                        if workoutManager.hasNotLocationAuthorization {
                            isShowingAlert.toggle()
                        } else {
                            workoutManager.showingPrecount.toggle()
                        }
                    } label: {
                        Image(.startButton)
                    }
                }
                .alert(isPresented: $isShowingAlert) {
                    // TODO: - Magic number, Magic String
                    Alert(title: Text("위치 권한이 허용되지 않았습니다."),
                          message: Text("원활한 앱 사용을 위해\n아이폰의 설정 앱에서 SoccerBeat의 위치 권한을 허용한 후 재실행 해주세요."),
                          dismissButton: .default(Text("요청하기"), action: requestAuthorizationIfNeeded))
                }
            } else {
                PrecountView()
            }
        }
        .buttonStyle(.borderless)
    }
    
    private func requestAuthorizationIfNeeded() {
        if workoutManager.hasNotLocationAuthorization || workoutManager.hasNotHealthAuthorization {
            workoutManager.requestAuthorization()
        }
    }
}

#Preview {
    @StateObject var workoutManager = WorkoutManager()
    
    return StartView()
        .environmentObject(workoutManager)
}
