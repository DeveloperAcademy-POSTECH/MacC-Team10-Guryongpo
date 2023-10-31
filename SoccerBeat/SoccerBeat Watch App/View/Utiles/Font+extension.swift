//
//  Font+extension.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/30/23.
//

import SwiftUI

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
*/

extension Font {
    
    // MARK: - Game Start
    
    public static let gameCountDown = Font.sfProText(size: 68, isItalic: true)
    public static let buttonTitle = Font.notoSans(size: 30, isItalic: true)
    
    // MARK: - Game Progress
    
    public static let zoneCapsule = Font.sfCompactText(size: 12, weight: .semibold, isItalic: true)
    public static let beatPerMinute = Font.sfProText(size: 56, weight: .black, isItalic: true)
    public static let distanceTimeNumber = Font.sfCompactText(size: 18, weight: .semibold, isItalic: true)
    public static let distanceTimeText = Font.sfCompactText(size: 12)
    public static let speedStop = Font.sfCompactText(size: 12, weight: .light, isItalic: true)

    // MARK: - Game Stop
    
    public static let stopEnd = Font.sfCompactText(size: 14, weight: .medium)
    public static let wiseSaying = Font.notoSans(size: 26, isItalic: true)
    
    // MARK: - After Game Data, Summary View
    
    public static let summaryContent = Font.notoSans(size: 26, isItalic: true)
    public static let summaryTraillingTop = Font.sfCompactText(size: 13.5)
    public static let summaryLeadingBottom = Font.sfCompactText(size: 13.5)
}

fileprivate extension Font {
    static func sfCompactText(size fontSize: CGFloat, weight: SFCompactText = .regular,
                              isItalic: Bool = false) -> Font {
        let font = Font.custom("\(SoccerBeat_Watch_App.SFCompactText.fontName)-\(weight.capitalized)",
                               size: fontSize)
        return isItalic ? font.italic() : font
    }
    
    static func sfProText(size fontSize: CGFloat, weight: SFProText = .black,
                          isItalic: Bool = false) -> Font {
        let font = Font.custom("\(SoccerBeat_Watch_App.SFProText.fontName)-\(weight.capitalized)",
                               size: fontSize)
        return isItalic ? font.italic() : font
    }
    
    static func notoSans(size fontSize: CGFloat, weight: NotoSansKR = .regular, isItalic: Bool = false) -> Font {
        let font = Font.custom("\(SoccerBeat_Watch_App.NotoSansKR.fontName)-\(weight.capitalized)",
                               size: fontSize)
        return isItalic ? font.italic() : font
    }
}

private enum SFCompactText: String {
    static let fontName = String(describing: Self.self)
    
    case medium
    case light
    case semibold
    case regular
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}

private enum SFProText: String {
    static let fontName = String(describing: Self.self)
    
    case black
    case heavy
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}

private enum NotoSansKR: String {
    static let fontName = String(describing: Self.self)
    
    case regular
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}
