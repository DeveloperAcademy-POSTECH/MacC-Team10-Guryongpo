//
//  SummaryComponent.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct SummaryComponent: View {
    let title: String  // "활동량"
    let content: String  // "Text"
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color.columnContent)
                Text("\(content)")
                    .foregroundStyle(.summaryGradient)
                    .font(.summaryContent)
                    .padding()
                    .scaledToFit()
                
            }.padding(.init(top: 22, leading: 0, bottom: 0, trailing: 0))
            
            ZStack {
                Rectangle()
                    .fill(Color.columnTitle)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 26, alignment: .top)
                HStack {
                    Image("BlueHeart")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 25, maxHeight: 25)
                        .padding(.horizontal)
                    Spacer()
                    Text(title)
                        .font(.summaryTraillingTop)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: 7.2))
        .padding(.vertical)
    }
}

#Preview {
    SummaryComponent(title: "활동량", content: "2.1KM")
}
