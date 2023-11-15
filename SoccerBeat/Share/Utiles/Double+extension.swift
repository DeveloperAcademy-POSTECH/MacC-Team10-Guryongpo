//
//  Double+extension.swift
//  SoccerBeat
//
//  Created by Gucci on 11/15/23.
//

import Foundation

extension Double {
    func rounded(at point: Int = 1) -> String {
        String(format: "%.\(point)f", self)
    }
}
