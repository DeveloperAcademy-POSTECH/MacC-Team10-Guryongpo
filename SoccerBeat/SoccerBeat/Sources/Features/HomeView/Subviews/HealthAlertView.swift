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
        ZStack {
            Button {
                showingAlert.toggle()
            } label: {
                Text("확인")
                    .padding(.horizontal)
                    .overlay {
                        Capsule()
                            .stroke(style: .init(lineWidth: 0.8))
                            .frame(height: 40)
                            .foregroundColor(.brightmint)
                    }
            }
            .offset(y: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.healthAlert)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

#Preview {
    HealthAlertView(showingAlert: .constant(true))
}
