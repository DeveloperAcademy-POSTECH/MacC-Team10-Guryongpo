//
//  ElapsedTimeView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/23/23.
//

import SwiftUI

// TODO: - 일시정지했을 때 경기 시간 그대로 흐르고 나중에 합산됨
struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    @State private var timeFormatter = ElapsedTimeFormatter()

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        return formattedString
    }
}

#Preview {
    ElapsedTimeView()
}
