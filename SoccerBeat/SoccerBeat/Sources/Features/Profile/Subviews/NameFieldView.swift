//
//  NameFieldView.swift
//  SoccerBeat
//
//  Created by jose Yun on 4/18/24.
//

import SwiftUI

struct NameFieldView: View {
    @State private var userName = ""
    let nameLength = 14
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if !userName.isEmpty {
                    Text(userName)
                        .foregroundStyle(.clear)
                        .padding(.horizontal, 32)
                        .frame(height: 40)
                        .overlay {
                            Capsule()
                                .stroke(style: .init(lineWidth: 0.8))
                                .frame(height: 40)
                                .foregroundColor(userName.count >= nameLength + 1 ? .red : .brightmint)
                        }
                }
                
                TextField("Name", text: $userName)
                    .padding(.horizontal, 32)
                    .frame(height: 40)
                    .limitText($userName, to: nameLength)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .onChange(of: userName) { _ in
                        UserDefaults.standard.set(userName, forKey: "userName")
                    }
            }
        }
        .offset(y: 24)
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
}

#Preview {
    NameFieldView()
}
