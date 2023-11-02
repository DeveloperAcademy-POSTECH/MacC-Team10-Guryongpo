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
                    .foregroundStyle(mainColor)
            }
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Text("\(nativeTitle)")
                        .font(.custom("SFProText-Regular", size: 14))
                    Spacer()
                }
                .padding()
                
                ZStack {
                    LightRectangleView()
                    VStack {
                        Text("2023.10.01 - 11.12")
                        BarMinMaxGraphView(color: Gradient(colors:[Color(hex: "FF007A")]), data: HeartBeatlast12Months)
                            .frame(width: 260, height: 90)
                            .padding(.vertical)
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
                    }
                }
                .frame(height: 230)
            }
            .padding()
            
            ZStack {
                LightRectangleView()
                HStack {
                    FormattedRecordAnalytics(recordType: "최고 기록", value: "1.5")
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    FormattedRecordAnalytics(recordType: "최저 기록", value: "1.0")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .frame(height: 80)
            .padding()
            
            Spacer()
                .frame(height: 35)
            
            VStack(alignment: .leading) {
                Text("SoccerBeat의 한 마디")
                    .font(.custom("나중에 추가", size: 16))
                RandomComment()
                    .font(.custom("나중에 추가", size: 28))
                Spacer()
            }
            .frame(width: 280)
        }
        .padding(.horizontal)
    }
}

#Preview {
    AnalyticsDetailView(graphType: .distance)
}

struct FormattedRecordAnalytics: View {
    var recordType: String
    var value: String = "-"
    var date: Date = Date()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recordType)
                .font(.custom("SFProText-Regular", size: 10))
            Text("\(dateFormatter.string(from: date))")
                .font(.custom("SFProText-Regular", size: 10))
            Text("\(value) km")
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
