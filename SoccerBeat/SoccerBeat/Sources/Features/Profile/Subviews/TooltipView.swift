//
//  TooltipView.swift
//  SoccerBeat
//
//  Created by Gucci on 11/21/23.
//

import SwiftUI

struct TooltipView<Content: View>: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Binding var isVisible: Bool
    let alignment: Edge
    let content: () -> Content
    let arrowOffset = CGFloat(8)

    private var oppositeAlignment: Alignment {
        let result: Alignment
        switch alignment {
        case .top: result = .bottom
        case .bottom: result = .top
        case .leading: result = .trailing
        case .trailing: result = .leading
        }
        return result
    }

    private var theHint: some View {
        ZStack {
            LightRectangleView(alpha: 0.8,
                               color: .tooltipBackgroundColor,
                               radius: 15.0)
            
            content()
        }
        .background(alignment: oppositeAlignment) {
            // 화살표 방향 뷰
            Rectangle()
                .fill(Color.clear)
                .border(.gray)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(45))
                .offset(x: alignment == .leading ? arrowOffset : 0)
                .offset(x: alignment == .trailing ? -arrowOffset : 0)
                .offset(y: alignment == .top ? arrowOffset : 0)
                .offset(y: alignment == .bottom ? -arrowOffset : 0)
        }
        .padding()
        .fixedSize()
    }

    var body: some View {
        if isVisible {
            GeometryReader { proxy1 in

                // .hidden()을 풀어보면 원래 힌트가 어느 부분에서 나오는지 알 수 있습니다.
                theHint
                    .hidden()
                    .overlay {
                        GeometryReader { proxy2 in

                            // 힌트
                            theHint
                                .drawingGroup()
                                .shadow(radius: 4)

                                // 힌트 뷰의 센터값 조정
                                .offset(
                                    x: -(proxy2.size.width / 2) + (proxy1.size.width / 2),
                                    y: -(proxy2.size.height / 2) + (proxy1.size.height / 2)
                                )
                                // 엣지 방향에 맞춰 뾰족 방향 배치
                                .offset(x: alignment == .leading ? (-proxy2.size.width / 2) - (proxy1.size.width / 2) : 0)
                                .offset(x: alignment == .trailing ? (proxy2.size.width / 2) + (proxy1.size.width / 2) : 0)
                                .offset(y: alignment == .top ? (-proxy2.size.height / 2) - (proxy1.size.height / 2) : 0)
                                .offset(y: alignment == .bottom ? (proxy2.size.height / 2) + (proxy1.size.height / 2) : 0)
                        }
                    }
            }
            .onTapGesture {
                isVisible.toggle()
            }
        }
    }
}

#Preview {
    @State var showTooltip = true
    
    return Text("Hello World")
        .overlay {
            TooltipView(isVisible: $showTooltip, alignment: .top) {
                Text("Hint 내용입니다.")
                    .padding()
            }
        }
        .onTapGesture {
            showTooltip.toggle()
        }
}
