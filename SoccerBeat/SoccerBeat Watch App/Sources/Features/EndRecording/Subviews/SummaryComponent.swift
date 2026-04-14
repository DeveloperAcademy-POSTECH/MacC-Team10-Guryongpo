//
//  SummaryComponent.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct SummaryComponent: View {
    let title: String
    let content: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(Color.columnTitle)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 24, maxHeight: 26, alignment: .top)
                HStack {
                    Image(.blueHeart)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 12, maxHeight: 12)
                        .padding(.leading, 5)
                    Text(LocalizedStringKey(title))
                        .font(.distanceTimeText)
                        .kerning(-0.8)
                        .foregroundStyle(.white)
                        Spacer()
                }
            }
            
            ZStack {
                Rectangle()
                    .foregroundStyle(Color.columnContent)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .top)
                
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(content)
                            .foregroundStyle(.summaryGradient)
                            .font(.summaryContent)
                        
                        Text(unit)
                            .foregroundStyle(.summaryGradient)
                            .font(.summaryUnit)
                        
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7.2))
    }
}

#Preview {
    VStack(spacing: 4) {
        HStack(spacing: 4) {
            SummaryComponent(title: "跑步距离", content: "2.1", unit: "KM")
            SummaryComponent(title: "跑步距离", content: "2.1", unit: "KM")
        }
        HStack(spacing: 4) {
            SummaryComponent(title: "跑步距离", content: "2.1", unit: "KM")
            SummaryComponent(title: "跑步距离", content: "2.1", unit: "KM")
        }
    }
    .padding(.all)
    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
}
