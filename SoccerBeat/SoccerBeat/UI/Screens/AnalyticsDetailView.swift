//
//  AnalyticsDetailView.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/1/23.
//

import SwiftUI

enum GraphEnum {
    case distance
    case sprint
    case speed
    case BPM
}

struct AnalyticsDetailView: View {
    
    var graphType: GraphEnum
    private var mainColor: LinearGradient {
        switch graphType {
        case .distance:
            return .zone2Bpm
        case .sprint:
            return .zone4Bpm
        case .speed:
            return .zone1Bpm
        case .BPM:
            return .zone3Bpm
        }
    }
    
    private var englishTitle: String {
        switch graphType {
        case .distance:
            return "MF - distance"
        case .sprint:
            return "FW - sprint"
        case .speed:
            return "DF - speed"
        case .BPM:
            return "Soccer BPM"
        }
    }
    
    private var nativeTitle: String {
        switch graphType {
        case .distance:
            return "활동량 (MF)"
        case .sprint:
            return "스프린트 횟수 (FW)"
        case .speed:
            return "속도 (DF)"
        case .BPM:
            return "심박수"
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("The quality of a")
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                    .foregroundStyle(mainColor)
                
                Text("\(englishTitle)")
                    .font(.custom("SFProText-HeavyItalic", size: 36))
                .foregroundStyle(mainColor)            }
            
            VStack {
                HStack {
                    Text("\(nativeTitle)")
                        .font(.custom("SFProText-Regular", size: 14))
                    Spacer()
                }
                
                ZStack {
                    LightRectangleView()
                }
                .frame(height: 230)
            }
            .padding()
            
            
            ZStack {
                LightRectangleView()
                
                HStack {
                    FormattedRecordAnalytics(recordType: "최고 기록" )
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    FormattedRecordAnalytics(recordType: "최저 기록")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }.frame(height: 80)
                .padding()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("SoccerBeat의 한 마디")
                        .font(.custom("SFProText-Medium", size: 16))
                    Spacer()
                }
                RandomComment()
                    .font(.custom("SFProText-Heavy", size: 28))
            }.padding()
        }.padding(.horizontal)
    }
}

#Preview {
    AnalyticsDetailView(graphType: .BPM)
}

struct FormattedRecordAnalytics: View {
    var recordType: String
    var value: Double = 1.5
    var date: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recordType)
                .font(.custom("SFProText-Regular", size: 10))
            Text("\(date.formatted())")
                .font(.custom("SFProText-Regular", size: 10))
            Text("\(value)")
                .font(.custom("SFProText-HeavyItalic", size: 14))
                .padding(.top)
        }
    }
}

struct RandomComment: View {
    @State private var text: String = "..Like son\nGood\nPlayer"
    var body: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .onAppear {
                if let decoded: PhraseResponse = Bundle.main.decode(by: "Phrase.json"),
                   let phrase = decoded.phrase.randomElement() {
                    self.text = phrase.saying
                }
            }
    }
}
