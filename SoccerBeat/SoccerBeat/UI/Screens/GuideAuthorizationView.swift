//
//  GuideAuthorizationView.swift
//  SoccerBeat
//
//  Created by jose Yun on 3/22/24.
//

import SwiftUI

struct GuideAuthorizationView: View {
    var healthAuthorization: Bool
    var body: some View {
        VStack {
            
            if healthAuthorization {
                
                Button("건강 권한 설정하기") {
                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                       let url = URL(string: "\(UIApplication.openSettingsURLString)&path=HEALTH/\(BUNDLE_IDENTIFIER)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)

                    }
                }
                .buttonStyle(BorderedButtonStyle())
            } else {
                Button("위치 권한 설정하기") {
                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                       let url = URL(string: "\(UIApplication.openSettingsURLString)&body=LOCATION/\(BUNDLE_IDENTIFIER)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
    }
}

#Preview {
    GuideAuthorizationView(healthAuthorization: false)
}
