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
 
 Family: Noto Sans
 - NotoSans-Regular
 - NotoSans-Black
 - NotoSans-BlackItalic
*/

extension Font {
    
    // MARK: - Game Start
    
    public static let gameCountDown = Font.sfProText(size: 68).italic()
    public static let buttonTitle = Font.notoSans(size: 30).italic()
    
    // MARK: - Game Progress
    
    public static let zoneCapsule = Font.sfCompactText(size: 12, weight: .semiboldItalic)
    public static let beatPerMinute = Font.sfProText(size: 36, weight: .heavyItalic)
    public static let bpmUnit = Font.sfProText(size: 18, weight: .heavyItalic)
    public static let distanceTimeNumber = Font.sfCompactText(size: 18, weight: .semiboldItalic)
    public static let distanceTimeText = Font.sfCompactText(size: 12)
    public static let speedStop = Font.sfCompactText(size: 12, weight: .lightItalic)

    // MARK: - Game Stop
    
    public static let stopEnd = Font.sfCompactText(size: 14, weight: .medium)
    public static let wiseSaying = Font.notoSans(size: 18, weight: .black).italic()
    
    // MARK: - After Game Data, Summary View
    
    public static let summaryContent = Font.notoSans(size: 26, weight: .blackItalic)
    public static let summaryTraillingTop = Font.sfCompactText(size: 13.5)
    public static let summaryLeadingBottom = Font.sfCompactText(size: 13.5)
    public static let summaryDoneButton = Font.sfCompactText(size: 13.5, weight: .semiboldItalic)
}

fileprivate extension Font {
    static func sfCompactText(size fontSize: CGFloat, weight: SFCompactText = .regular) -> Font {
        Font.custom("\(SoccerBeat_Watch_App.SFCompactText.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
    
    static func sfProText(size fontSize: CGFloat, weight: SFProText = .blackItalic) -> Font {
        Font.custom("\(SoccerBeat_Watch_App.SFProText.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
    
    static func notoSans(size fontSize: CGFloat, weight: NotoSans = .regular) -> Font {
        Font.custom("\(SoccerBeat_Watch_App.NotoSans.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
}

private enum SFCompactText: String {
    static let fontName = String(describing: Self.self)
    
    case medium
    case lightItalic
    case semiboldItalic
    case regular
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}

private enum SFProText: String {
    static let fontName = String(describing: Self.self)
    
    case blackItalic
    case heavyItalic
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}

private enum NotoSans: String {
    static let fontName = String(describing: Self.self)
    
    case regular
    case black
    case blackItalic
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}
