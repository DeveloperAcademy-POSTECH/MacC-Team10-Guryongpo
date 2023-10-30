//
//  Font+extension.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/30/23.
//

import SwiftUI

extension Font {
    
    // MARK: - Game Start
    
    public static let gameCountDown = Font.custom("SFProText-BlackItalic", size: 68)
    public static let buttonTitle = Font.custom("NotoSansKR-Regular", size: 30).italic()
    
    // MARK: - Game Progress
    
    public static let zoneCapsule = Font.custom("SFCompactText-SemiboldItalic", size: 12)
    public static let beatPerMinute = Font.custom("SFProText-BlackItalic", size: 56)
    public static let distanceTimeNumber = Font.custom("SFCompactText-SemiboldItalic", size: 18)
    public static let distanceTimeText = Font.custom("SFCompactText-Regular", size: 12)
    public static let speedStop = Font.custom("SF-Compact-Text-LightItalic", size: 12)

    // MARK: - Game Stop
    
    public static let stopEnd = Font.custom("SFCompactText-Medium", size: 14)
    public static let wiseSaying = Font.custom("NotoSansKR-Regular", size: 26).italic()
    
    // MARK: - After Game Data, Summary View
    public static let summaryContent = Font.custom("NotoSansKR-Regular", size: 26).italic()
    public static let summaryTraillingTop = Font.custom("SFCompactText-Regular", size: 13.5)
    public static let summaryLeadingBottom = Font.custom("SFCompactText-Regular", size: 13.5)
}

/*
 Family: SF Compact Text
 - SFCompactText-Regular
 - SFCompactText-LightItalic
 - SFCompactText-Medium
 - SFCompactText-SemiboldItalic
 Family: SF Pro Text
 - SFProText-HeavyItalic
 - SFProText-BlackItalic
 
 - NotoSansKR-Regular

extension Font {
    static func SFCompactText(size fontSize: CGFloat, weight: Font.Weight) -> Font {
        let familyName = "SFCompactText"

        var weightString: String
        switch weight {
        case .black:
            weightString = "Black"
        case .bold:
            weightString = "Blod"
        case .heavy:
            weightString = "ExtraBold"
        case .ultraLight:
            weightString = "ExtraLight"
        case .light:
            weightString = "Light"
        case .medium:
            weightString = "Medium"
        case .regular:
            weightString = "Regular"
        case .semibold:
            weightString = "SemiBold"
        case .thin:
            weightString = "Thin"
        default:
            weightString = "Regular"
        }
        return Font.custom("\(familyName)-\(weightString)", size: fontSize)
    }
}

 */
