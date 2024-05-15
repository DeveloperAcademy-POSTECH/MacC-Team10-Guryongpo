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
                        if workoutManager.hasNoLocationAuthorization || workoutManager.hasNoHealthAuthorization {
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
                    Alert(title: Text("위치 권한 또는 건강 정보 권한이 허용되지 않았습니다."),
                          message: Text("원활한 앱 사용을 위해\n아이폰의 설정 앱에서 SoccerBeat의 위치 권한 또는 설정의 건강에서 건강 권한을 허용한 후 다시 실행해주세요."),
                          dismissButton: .default(Text("요청하기"), action: { requestAuthorization()
                    }))
                }
            } else {
                PrecountView()
            }
        }
        .buttonStyle(.borderless)
    }

    private func requestAuthorization() {
        workoutManager.requestAuthorization()
    }
}

#Preview {
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()
    
    return StartView()
        .environmentObject(workoutManager)
}
