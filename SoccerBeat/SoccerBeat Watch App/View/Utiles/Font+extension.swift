//
//  Font+extension.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/30/23.
//

import SwiftUI

extension Font {
    
    // MARK: - Game Start
    
    public static let gameCountDown = Font.custom("SF-Pro-Text-BlackItalic", size: 68)
    public static let buttonTitle = Font.custom("NotoSansKR-Regular", size: 30).italic()
    
    // MARK: - Game Progress
    
    public static let zoneCapsule = Font.custom("SF-Compact-Text-SemiboldItalic", size: 12)
    public static let beatPerMinute = Font.custom("SF-Pro-Text-BlackItalic", size: 56)
    public static let distanceTimeNumber = Font.custom("SF-Compact-Text-SemiboldItalic", size: 18)
    public static let distanceTimeText = Font.custom("SF-Compact-Text", size: 12)
    public static let speedStop = Font.custom("SF-Compact-Text-LightItalic", size: 12)

    // MARK: - Game Stop
    
    public static let stopEnd = Font.custom("SF-Compact-Text-Medium", size: 14)
    public static let wiseSaying = Font.custom("NotoSansKR-Regular", size: 26).italic()
    
    // MARK: - After Game Data, Summary View
    public static let summaryNumber = Font.custom("NotoSansKR-Regular", size: 26).italic()
    public static let summaryTraillingTop = Font.custom("SF-Compact-Text-Regular", size: 13.5)
    public static let summaryLeadingBottom = Font.custom("SF-Compact-Text-Regular", size: 13.5)
}
