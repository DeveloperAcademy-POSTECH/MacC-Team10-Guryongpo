//
//  CheckboxStyle.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 4.0)
                        .foregroundStyle(.white)
                        .frame(width: 21, height: 21)
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.cyan)
                            .bold()
                    }
                }
                configuration.label
            }
        })
    }
}
