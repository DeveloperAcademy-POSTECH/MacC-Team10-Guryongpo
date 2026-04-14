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
                showingAlert.toggle()
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
                Text("정보 수집을 위해 다음과 같은 접근 권한을 사용하고 있습니다.")
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 20)
                
                Group {
                    Text("위치(필수): 사용자의 필드 위 위치를 저장하기 위해 사용합니다.")
                    Text("백그라운드 위치(필수): 사용자의 필드 위 위치를 저장하기 위해 사용합니다.")
                    Text("헬스 정보(필수): 사용자의 경기 데이터를 저장하기 위해 사용합니다.")
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
