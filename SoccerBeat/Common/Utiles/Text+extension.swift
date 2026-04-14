//
//  Text+Extension.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/21/23.
//

import SwiftUI
extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) { _ in
                if text.wrappedValue.count > characterLimit {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.03) {
                        text.wrappedValue = String(text.wrappedValue.dropLast())
                    }
                }
            }
    }
}
