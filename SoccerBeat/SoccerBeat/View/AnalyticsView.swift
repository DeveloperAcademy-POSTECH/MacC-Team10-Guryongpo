//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    
    var isBool = false
    @State var isShowingDistance: Bool = false
    @State var isShowingSprint: Bool = true
    @State var isShowingHeartRate: Bool = false
    @State var isShowingSpeed: Bool = false
    @State var showingText: String = "스프린트 (FW)"
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text("Hello, Son")
                        Text("How you like")
                        Text("that?")
                    }
                    .foregroundStyle(
                        .linearGradient(colors: [.skyblue, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    .kerning(-1.5)
                    .padding(.leading, 10.0)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.bottom)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        CheckboxToggleStyle(isOn: $isShowingSprint, showingText: $showingText, text: "스프린트 (FW)")
                        CheckboxToggleStyle(isOn: $isShowingHeartRate, showingText: $showingText, text: "심박수 (DF)")
                    }
                    
                    VStack(alignment: .leading) {
                        CheckboxToggleStyle(isOn: $isShowingDistance, showingText: $showingText, text: "활동량 (MF)")
                        CheckboxToggleStyle(isOn: $isShowingSpeed, showingText: $showingText, text: "최대 속도 (DF)")
                    }
                }
                
                VStack(alignment: .leading) {
                    ZStack {
                        LightRectangleView()
                        if isShowingSprint {
                            BarMinMaxGraphView(color: Gradient(colors: [Color(hex:  "0EB7FF"), .white]), data: SprintDatalast30Days)
                                .padding()
                        }
                        
                        if isShowingDistance {
                            LineGraphView(color: Color(hex: "FF007A"), data: DistanceDummyData)
                                .padding()
                        }
                        
                        if isShowingHeartRate {
                            BarMinMaxGraphView(color: Gradient(colors:[Color(hex: "FF007A")]), data: HeartBeatlast12Months)
                                .padding()
                        }
                        
                        if isShowingSpeed {
                            LineGraphView(color: .white)
                                .padding()
                        }
                    }
                    
                    HStack {
                        FormattedRecord(recordType: "최고 기록")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay {
                                LightRectangleView()
                            }
                        
                        FormattedRecord(recordType: "최저 기록")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay {
                                LightRectangleView()
                            }
                        
                    }
                }.padding(.horizontal)
                    .onChange(of: [isShowingDistance, isShowingSpeed, isShowingSprint, isShowingHeartRate] ) { newValue in
                        disableAll(text: showingText)
                        // activate only one selection
                    }
            }
        }
    }
    
    func disableAll(text: String) {
        
        self.isShowingSpeed = false
        self.isShowingSprint = false
        self.isShowingHeartRate = false
        self.isShowingDistance = false
        if text == "활동량 (MF)" {
            isShowingDistance = true
        } else if text == "최대 속도 (DF)" {
            isShowingSpeed = true
        } else if text == "심박수 (DF)" {
            isShowingHeartRate = true
        } else {
            isShowingSprint = true
        }
    }
}

#Preview {
    AnalyticsView()
}

struct FormattedRecord: View {
    var recordType: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(recordType)
                .font(.system(size: 10))
            Text("2023.10.12")
                .font(.system(size: 10))
            Text("1.5km")
                .font(.system(size: 14))
                .italic()
                .bold()
                .padding(.top)
        }
    }
}
