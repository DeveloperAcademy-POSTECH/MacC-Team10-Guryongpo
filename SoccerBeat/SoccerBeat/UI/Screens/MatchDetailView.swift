//
//  MatchDetailView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI
import Charts

struct MatchDetailView: View {
    var body: some View {
        ScrollView {
            ZStack {
                Image("BackgroundPattern")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 0)
                
                VStack {
                    MatchDetailView01()
                    MatchDetailView02()
// MARK: 추후 HeartRate 추가
//                    MatchDetailView03()
                    MatchDetailView04()
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct MatchDetailView01: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("2023.11.11")
                        .font(.custom("나중에 추가", size: 10))
                    Spacer()
                        .frame(height: 10)
                    Text("경기 시간")
                        .font(.custom("SFProText-HeavyItalic", size: 25))
                    Text("74:12")
                        .font(.custom("SFProText-HeavyItalic", size: 25))
                }
                .foregroundStyle(.white)
                Spacer()
            }
            .padding([.top, .leading])
            
            HStack {
                Text("Information")
                    .padding()
                Spacer()
            }
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 14))
            
            Spacer()
                .frame(height: 45)
            
            VStack(alignment: .leading) {
                Text("장점")
                    .font(.custom("나중에 추가", size: 16))
                Text("당신은 두 개의 심장")
                    .font(.custom("SFProText-HeavyItalic", size: 32))
            }
            .foregroundStyle(.white)
            
            Spacer()
                .frame(height: 40)
            
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Image("HeartbeatSignPink")
                    Text("뛴 거리")
                        .font(.custom("나중에 추가", size: 16))
                    Text("2.2 km")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                        .foregroundStyle(Color.deeppink)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Image("HeartbeatSign")
                    Text("칼로리")
                        .font(.custom("나중에 추가", size: 16))
                    Text("320 Kcal")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                }
                Spacer()
            }
            .frame(height: 100)
            .overlay {
                Rectangle()
                    .opacity(0.1)
            }
            
            Spacer()
                .frame(height: 16)
            
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Image("HeartbeatSign")
                    Text("스프린트")
                        .font(.custom("나중에 추가", size: 16))
                    Text("3 Times")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Image("HeartbeatSign")
                    Text("최고 속도")
                        .font(.custom("나중에 추가", size: 16))
                    Text("22 km/h")
                        .font(.custom("SFProText-HeavyItalic", size: 30))
                }
                Spacer()
            }
            .frame(height: 100)
            .overlay {
                Rectangle()
                    .opacity(0.1)
            }
            Spacer()
                .frame(height: 120)
        }
    }
}

struct MatchDetailView02: View {
    var body: some View {
        VStack {
            HStack {
                Text("Playing Area")
                    .padding()
                Spacer()
            }
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 14))
            
            Spacer()
                .frame(height: 50)
            
            VStack {
                Text("활동 히트맵")
                    .font(.custom("SFProText-HeavyItalic", size: 16))
                VStack {
                    Text("혹시")
                    Text("김민재인가요?")
                    Text("하프라인 아래의")
                    Text("활동량이")
                    Text("매우 좋으시군요?!")
                }
                .font(.custom("SFProText-HeavyItalic", size: 32))
            }
            .foregroundStyle(.white)
            
            Spacer()
                .frame(height: 40)
            
            Image("MatchDetail02")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
        }
        Spacer()
            .frame(height: 120)
    }
}

struct MatchDetailView03: View {
    var body: some View {
        VStack {
            HStack {
                Text("Heartbeat")
                    .padding()
                Spacer()
            }
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 14))
            
            Spacer()
                .frame(height: 20)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder()
                    .frame(width: 358, height: 311)
                VStack {
                    Image("HeartbeatSign")
                    Text("BPM")
                        .font(.custom("SFProText-HeavyItalic", size: 14))
                    BarMinMaxGraphView(color: Gradient(colors:[Color(hex: "FF007A")]), data: HeartBeatlast12Months)
                        .frame(width: 217, height: 87)
                    Spacer()
                        .frame(height: 15)
                    HStack(spacing: 15) {
                        VStack {
                            Text("110")
                                .font(.custom("나중에 추가", size: 12))
                            Text("1일")
                                .font(.custom("나중에 추가", size: 10))
                        }
                        VStack {
                            Text("110")
                                .font(.custom("나중에 추가", size: 12))
                            Text("11일")
                                .font(.custom("나중에 추가", size: 10))
                        }
                        VStack {
                            Text("180")
                                .font(.custom("SFProText-HeavyItalic", size: 12))
                            Text("13일")
                                .font(.custom("나중에 추가", size: 10))
                        }
                        VStack {
                            Text("120")
                                .font(.custom("나중에 추가", size: 12))
                            Text("15일")
                                .font(.custom("나중에 추가", size: 10))
                        }
                        VStack {
                            Text("110")
                                .font(.custom("나중에 추가", size: 12))
                            Text("17일")
                                .font(.custom("나중에 추가", size: 10))
                        }
                    }
                    .frame(width: 222, height: 41)
                    Spacer()
                        .frame(height: 40)
                    VStack(alignment: .leading) {
                        Text("최고 심박수")
                            .font(.custom("나중에 추가", size: 10))
                        Text("180 BPM")
                            .font(.custom("SFProText-HeavyItalic", size: 24))
                    }
                    .padding(.leading, 20)
                    .kerning(-0.41)
                }
            }
            Spacer()
                .frame(height: 120)
        }
    }
}

struct MatchDetailView04: View {
    var body: some View {
        VStack {
            HStack {
                Text("Sprint Time")
                    .padding()
                Spacer()
            }
            .foregroundStyle(
                .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .font(.custom("SFProText-HeavyItalic", size: 14))
            
            Spacer()
                .frame(height: 20)
            
            VStack(spacing: 10) {
                VStack {
                    HStack {
                        Image("Running")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                        Text("1회")
                            .font(.custom("나중에 추가", size: 24))
                    }
                Text("15분, 속력: 21km/h")
                        .font(.custom("나중에 추가", size: 30))
                }
                .frame(width: 360, height: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder()
                }
                VStack {
                    HStack {
                        Image("Running")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                        Text("2회")
                            .font(.custom("나중에 추가", size: 24))
                    }
                Text("15분, 속력: 21km/h")
                        .font(.custom("나중에 추가", size: 30))
                }
                .frame(width: 360, height: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder()
                }
                VStack {
                    HStack {
                        Image("Running")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                        Text("3회")
                            .font(.custom("나중에 추가", size: 24))
                    }
                Text("15분, 속력: 21km/h")
                        .font(.custom("나중에 추가", size: 30))
                }
                .frame(width: 360, height: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder()
                }
            }
        }
    }
}

#Preview {
    MatchDetailView()
}
