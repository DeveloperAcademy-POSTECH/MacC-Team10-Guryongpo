//
//  SummaryComponent.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/23/23.
//

import SwiftUI

struct SummaryComponent: View {
    var title: String = "활동량"
    var content: String = "Text"
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color.columnContent)
                Text("\(content)")
                    .foregroundStyle(.summaryGradient)
                    .fontWeight(.black)
                    .italic()
                    .font(.title)
                    .padding()
                
            }.padding(.init(top: 22, leading: 0, bottom: 0, trailing: 0))
            
            ZStack {
                Rectangle()
                    .fill(Color.columnTitle)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 26, alignment: .top)
                HStack {
//                    Image(systemName: "heart")
                    Image("BlueHeart")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 25, maxHeight: 25)
                        .padding(.horizontal)
                    Spacer()
                    Text(title)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
            }
            
            
                
                
        }
        .clipShape(RoundedRectangle(cornerRadius: 7.2))
    }
}

#Preview {
    SummaryComponent()
}
