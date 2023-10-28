//
//  MatchDetailView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchDetailView: View {
    var body: some View {
        TabView {
            MatchDetailView01()
            
            MatchDetailView02()
            
            MatchDetailView03()
            
            MatchDetailView04()
        }.tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()
    }
}

struct MatchDetailView01: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Information")
                        .padding()
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("2023.11.11")
                    
                    Text("경기 시간")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                    
                    Text("74:12")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                }
                
                Spacer()
                
                Image("MatchDetail01")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 100)
            }.padding(.top)
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 18))
        }
    }
}

struct MatchDetailView02: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Playing Area")
                        .padding()
                    Spacer()
                }
                
                Spacer()
                
                Image("MatchDetail02")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .padding(.bottom, 100)
            }.padding(.top)
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 18))
        }
    }
}

struct MatchDetailView03: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Heartbeat")
                        .padding()
                    Spacer()
                }
                
                Spacer()
                
                Image("MatchDetail03")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 100)
            }.padding(.top)
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 18))
        }
    }
}

struct MatchDetailView04: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Sprint Time")
                        .padding()
                    Spacer()
                }
                
                Spacer()
                
                Image("MatchDetail04")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 100)
            }.padding(.top)
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 18))
        }
    }
}

#Preview {
    MatchDetailView()
}
