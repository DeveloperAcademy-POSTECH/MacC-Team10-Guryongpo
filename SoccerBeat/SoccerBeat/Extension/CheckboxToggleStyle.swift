//
//  CheckboxStyle.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct CheckboxToggleStyle: View {
    @Binding var isOn: Bool
    @Binding var showingText: String
    var text: String
    var body: some View {
        Button(action: {
            isOn.toggle()
            if isOn {
                showingText = text
            }
            print(text)
        }, label: {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 4.0)
                        .foregroundStyle(.white)
                        .frame(width: 21, height: 21)
                    if isOn {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.cyan)
                            .bold()
                    }
                }
                Text(text)
                    .foregroundStyle(.white)
                    .opacity(0.8)
            }
        })
    }
}
