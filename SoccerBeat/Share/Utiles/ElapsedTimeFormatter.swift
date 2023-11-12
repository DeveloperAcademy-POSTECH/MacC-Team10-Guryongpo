//
//  ElapsedTimeFormatter.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import Foundation

final class ElapsedTimeFormatter: Formatter {
    private let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    // Minute - first, Secone - Last
    func spendingTimeDevidedColone(_ elapsedTime: TimeInterval) -> [String] {
        let calculatedSpendingTime = NSNumber(value: elapsedTime)
        var fourDigitSpendingTime = self.string(for: calculatedSpendingTime)
        if fourDigitSpendingTime?.count != 5 {
            fourDigitSpendingTime?.removeLast()
        }
        return fourDigitSpendingTime?.split(separator: ":").map { String($0) } ?? []
    }

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
