//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("최근 경기 분석")
                Spacer()
            }
            .padding(.leading)
            .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
            
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Running")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("활동량 (MF)")
                        }
                        Text("2.2 Km")
                            .font(.custom("SFProText-HeavyItalic", size: 32))
                            .foregroundStyle(.zone2Bpm)
                    }
                    Spacer()
                    Image("ActivityGraph")
                }
                .padding()
                .padding(.horizontal)
                .overlay {
                    LightRectangleView()
                }
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Running")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("스프린트 (FW)")
                        }
                        Text("10 Times")
                            .font(.custom("SFProText-HeavyItalic", size: 32))
                            .foregroundStyle(.zone3Bpm)
                    }
                    Spacer()
                    Image("SprintGraph")
                }
                .padding()
                .padding(.horizontal)
                .overlay {
                    LightRectangleView()
                }
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Running")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("최고 속도 (DF)")
                        }
                        Text("20 Km/h")
                            .font(.custom("SFProText-HeavyItalic", size: 32))
                            .foregroundStyle(.zone1Bpm)
                    }
                    Spacer()
                    Image("MaxSpeedGraph")
                }
                .padding()
                .padding(.horizontal)
                .overlay {
                    LightRectangleView()
                }
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Running")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("심박수")
                        }
                        Text("180 Bpm")
                            .font(.custom("SFProText-HeavyItalic", size: 32))
                            .foregroundStyle(.zone4Bpm)
                    }
                    Spacer()
                    Image("HeartrateGraph")
                }
                .padding()
                .padding(.horizontal)
                .overlay {
                    LightRectangleView()
                }
                
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    AnalyticsView()
}

//import SwiftUI
//import Charts
//
//struct AnalyticsView: View {
//    
//    var isBool = false
//    @State var isShowingDistance: Bool = false
//    @State var isShowingSprint: Bool = true
//    @State var isShowingHeartRate: Bool = false
//    @State var isShowingSpeed: Bool = false
//    @State var showingText: String = "스프린트 (FW)"
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                HStack {
//                    VStack(alignment: .leading, spacing: 0.0) {
//                        Text("Hello, Son")
//                        Text("How you like")
//                        Text("that?")
//                    }
//                    .foregroundStyle(
//                        .linearGradient(colors: [.skyblue, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .font(.custom("SFProText-HeavyItalic", size: 36))
//                    .kerning(-1.5)
//                    .padding(.horizontal)
//                    .padding(.leading, 10.0)
//                    Spacer()
//                }
//                .padding(.top, 30)
//                .padding(.bottom)
//                
//                Spacer()
//                
//                HStack {
//                    VStack(alignment: .leading) {
//                        CheckboxToggleStyle(isOn: $isShowingSprint, showingText: $showingText, text: "스프린트 (FW)")
//                        CheckboxToggleStyle(isOn: $isShowingHeartRate, showingText: $showingText, text: "심박수 (DF)")
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        CheckboxToggleStyle(isOn: $isShowingDistance, showingText: $showingText, text: "활동량 (MF)")
//                        CheckboxToggleStyle(isOn: $isShowingSpeed, showingText: $showingText, text: "최대 속도 (DF)")
//                    }
//                }
//                
//                VStack(alignment: .leading) {
//                    ZStack {
//                        LightRectangleView()
//                        if isShowingSprint {
//                            BarMinMaxGraphView(color: Gradient(colors: [Color(hex:  "0EB7FF"), .white]), data: SprintDatalast30Days)
//                                .padding()
//                        }
//                        
//                        if isShowingDistance {
//                            LineGraphView(color: Color(hex: "FF007A"), data: DistanceDummyData)
//                                .padding()
//                        }
//                        
//                        if isShowingHeartRate {
//                            BarMinMaxGraphView(color: Gradient(colors:[Color(hex: "FF007A")]), data: HeartBeatlast12Months)
//                                .padding()
//                        }
//                        
//                        if isShowingSpeed {
//                            LineGraphView(color: .white)
//                                .padding()
//                        }
//                    }
//                    
//                    HStack {
//                        FormattedRecord(recordType: "최고 기록")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .overlay {
//                                LightRectangleView()
//                            }
//                        
//                        FormattedRecord(recordType: "최저 기록")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .overlay {
//                                LightRectangleView()
//                            }
//                        
//                    }
//                }.padding(.horizontal)
//                    .onChange(of: [isShowingDistance, isShowingSpeed, isShowingSprint, isShowingHeartRate] ) { newValue in
//                        disableAll(text: showingText)
//                        // activate only one selection
//                    }
//            }
//        }
//    }
//    
//    func disableAll(text: String) {
//        
//        self.isShowingSpeed = false
//        self.isShowingSprint = false
//        self.isShowingHeartRate = false
//        self.isShowingDistance = false
//        if text == "활동량 (MF)" {
//            isShowingDistance = true
//        } else if text == "최대 속도 (DF)" {
//            isShowingSpeed = true
//        } else if text == "심박수 (DF)" {
//            isShowingHeartRate = true
//        } else {
//            isShowingSprint = true
//        }
//    }
//}
//

//
//struct FormattedRecord: View {
//    var recordType: String
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(recordType)
//                .font(.system(size: 10))
//            Text("2023.10.12")
//                .font(.system(size: 10))
//            Text("1.5km")
//                .font(.system(size: 14))
//                .italic()
//                .bold()
//                .padding(.top)
//        }
//    }
//}
