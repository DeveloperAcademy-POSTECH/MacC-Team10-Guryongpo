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
            ZStack {
                BackgroundImageView()
                
                VStack {
                    HStack {
                        Text("# 이번 경기 지표를 내 평균 능력치와 비교해 볼까요?")
                            .floatingCapsuleStyle()
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    
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
                    
                    let average = [3.0, 2.4, 3.4, 3.2, 2.8, 3.3]
                    let recent = [4.1, 3.0, 3.5, 3.8, 3.5, 2.8]
                    ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
                        .fixedSize()
                        .frame(width: 210, height: 210)
                    
                    Spacer().frame(height: 100)
                    
                    HStack {
                        Text("# 이번 경기 지표를 내 평균 능력치와 비교해 볼까요?")
                            .floatingCapsuleStyle()
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0.0) {
                            Text("My")
                            Text("Card Collection")
                        }
                        .font(.custom("SFProText-HeavyItalic", size: 36))
                        .kerning(-1.5)
                        .padding(.leading, 10.0)
                        Spacer()
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                }
            }
        }.onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
}

#Preview {
    ProfileView()
}
