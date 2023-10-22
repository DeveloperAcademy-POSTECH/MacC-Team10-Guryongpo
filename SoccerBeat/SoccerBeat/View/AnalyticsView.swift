//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    
    @State var isShowingDistance: Bool = false
    @State var isShowingSprint: Bool = false
    @State var isShowingHeartRate: Bool = false
    @State var isShowingSpeed: Bool = false
    @State var isOverGraphs: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkblue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hello, Son")
                        Text("How you like")
                        Text("that?")
                    }
                    Spacer()
                }
                .foregroundStyle(
                    .linearGradient(colors: [.skyblue, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.custom("SFProText-HeavyItalic", size: 36))
                .padding()
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Toggle(isOn: $isShowingSprint, label: {
                            Text("스프린트 (FW)")
                                .foregroundStyle(isOverGraphs ? .gray : .white)
                                .opacity(0.8)
                        })
                        .toggleStyle(CheckboxToggleStyle())
                        .disabled(isShowingSprint ? false : isOverGraphs)
                        
                        Toggle(isOn: $isShowingHeartRate, label: {
                            Text("심박수 (DF)")
                                .foregroundStyle(isOverGraphs ? .gray : .white)
                                .opacity(0.8)
                        })
                        .toggleStyle(CheckboxToggleStyle())
                        .disabled(isShowingHeartRate ? false : isOverGraphs)
                    }
                    
                    VStack(alignment: .leading) {
                        Toggle(isOn: $isShowingDistance, label: {
                            Text("활동량 (MF)")
                                .foregroundStyle(isOverGraphs ? .gray : .white)
                                .opacity(0.8)
                        })
                        .toggleStyle(CheckboxToggleStyle())
                        .disabled(isShowingDistance ? false : isOverGraphs)
                        
                        Toggle(isOn: $isShowingSpeed, label: {
                            Text("최대 속도 (DF)")
                                .foregroundStyle(isOverGraphs ? .gray : .white)
                                .opacity(0.8)
                        })
                        .toggleStyle(CheckboxToggleStyle())
                        .disabled(isShowingSpeed ? false : isOverGraphs)
                    }
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    ZStack {
                        LightRectangleView()
                        if isShowingSprint {
                            BarGraphView()
                                .padding()
                        }
                        
                        if isShowingDistance {
                            LineGraphView(data: DistanceDummyData)
                                .padding()
                        }
                        
                        if isShowingHeartRate {
                            BarMinMaxGraphView()
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
                }.padding()
            }.padding()
        }
        .onChange(of: [isShowingDistance, isShowingSprint, isShowingHeartRate, isShowingSpeed]) { newValue in
            if newValue.filter({ $0 == true }).count < 2 {
                isOverGraphs = false
            } else {
                isOverGraphs = true
            }
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
