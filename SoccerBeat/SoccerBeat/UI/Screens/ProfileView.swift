//
//  ProfileView.swift
//  SoccerBeat
//
//  Created by daaan on 11/17/23.
//

import SwiftUI

struct ProfileView: View {
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    @State var userName: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0.0) {
                        HStack(spacing: 0.0) {
                            Text("Hello, ")
                            TextField("Name", text: $userName)
                                .onChange(of: userName) { _ in
                                    UserDefaults.standard.set(userName, forKey: "userName")
                                }
                        }
                        Text("How you like that?")
                    }
                    .foregroundStyle(!isFlipped ?
                        .linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing) : .linearGradient(colors: [.titlegray, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    .kerning(-1.5)
                    .padding(.leading, 10.0)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 80)
                
                MyCardView(isFlipped: $isFlipped, viewModel: viewModel)
                PhotoSelectButtonView(viewModel: viewModel)
                    .opacity(isFlipped ? 1 : 0)
                    .padding()
            }
        }.onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
}

#Preview {
    ProfileView()
}
