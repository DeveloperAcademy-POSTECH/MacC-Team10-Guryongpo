//
//  GuideAuthorizationView.swift
//  SoccerBeat
//
//  Created by jose Yun on 3/22/24.
//

import SwiftUI

struct GuideAuthorizationView: View {
    let requestingAuth: Auth
    enum Auth {
        case health
        case location
    }
    var body: some View {
        VStack {
            if requestingAuth == .health {
                Button("건강 권한 설정하기") {
                    if let bundleIdentifier = Bundle.main.bundleIdentifier,
                       let url = URL(string: "\(UIApplication.openSettingsURLString)&path=HEALTH/\(bundleIdentifier)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                .buttonStyle(BorderedButtonStyle())
            } else {
                Button("위치 권한 설정하기") {
                    if let bundleIdentifier = Bundle.main.bundleIdentifier,
                       let url = URL(string: "\(UIApplication.openSettingsURLString)&body=LOCATION/\(bundleIdentifier)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
    }
}

#Preview {
    GuideAuthorizationView(requestingAuth: .health)
}
