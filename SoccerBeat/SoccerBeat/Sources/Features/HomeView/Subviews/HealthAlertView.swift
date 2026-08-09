//
//  HealthAlertView.swift
//  SoccerBeat
//
//  Created by daaan on 11/21/23.
//

import SwiftUI

struct HealthAlertView: View {
    @Binding var showingAlert: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            AccessPermissionView()
                .padding()
                .overlay{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white)
                        .padding()
                }
            
            Button {
                // Button 액션은 동기식이므로 Task에서 HealthKit 권한 요청을 수행합니다.
                Task { @MainActor in
                    do {
                        try await WorkoutManager.shared.requestAuthorization()
                    } catch {
                        NSLog("Health authorization request failed: \(error.localizedDescription)")
                    }

                    showingAlert = false
                    await WorkoutManager.shared.fetchWorkoutData()
                }
            } label: {
                Text("확인")
                    .padding(.horizontal)
                    .overlay {
                        Capsule()
                            .stroke(style: .init(lineWidth: 0.8))
                            .frame(height: 40)
                            .foregroundColor(.white)
                    }
            }
            Spacer()
        }
    }
}

struct AccessPermissionView: View {
    var body: some View {
        VStack(spacing: 25) {
            Text("앱 접근 권한 안내")
                .font(.headline)
                .foregroundColor(.white)
            
            Rectangle()
                .background(Color.white)
                .frame(height: 1)
            
            
            VStack(alignment: .leading, spacing: 20) {
                Text("저장된 경기 기록을 불러오기 위해 다음 접근 권한을 사용합니다.")
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 20)
                
                Group {
                    Text("Apple Health 읽기(선택): 경기 분석과 차트를 표시하는 데 사용합니다.")
                    Text("허용하지 않아도 프로필과 문의 등 다른 기능을 사용할 수 있습니다.")
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 20)
        .padding(20)
    }
}

#Preview {
    HealthAlertView(showingAlert: .constant(true))
}
