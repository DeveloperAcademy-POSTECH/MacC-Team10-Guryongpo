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
 - SPProText-RegularItalic
 - SFProText-SemiboldItalic
 - SFProText-Regular

 
 Family: SF Pro Display
 - SFProDisplay-HeavyItalic
 - SFProDisplay-SemiboldItalic
 - SFProDisplay-RegularItalic
 
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
    public static let scaleText = Font.sfCompactText(size: 12, weight: .semiboldItalic)
    public static let distanceTimeText = Font.sfCompactText(size: 12)
    public static let sprintText = Font.sfProText(size: 14, weight: .semiboldItalic)
    public static let speedStop = Font.sfCompactText(size: 12, weight: .lightItalic)
    public static let playTimeText = Font.sfProText(size: 12, weight: .regularItalic)
    public static let playTimeNumber = Font.sfProText(size: 44, weight: .blackItalic)

    // MARK: - Game Stop
    
    public static let stopEnd = Font.sfCompactText(size: 14, weight: .medium)
    public static let wiseSaying = Font.notoSans(size: 18, weight: .black).italic()
    
    // MARK: - After Game Data, Summary View
    
    public static let summaryContent = Font.notoSans(size: 26, weight: .blackItalic)
    public static let summaryTraillingTop = Font.sfCompactText(size: 13.5)
    public static let summaryLeadingBottom = Font.sfCompactText(size: 13.5)
    public static let summaryDoneButton = Font.sfCompactText(size: 13.5, weight: .semiboldItalic)
    
    // MARK: - MatchTotalView
    
    public static let matchTotalTitle = Font.sfProText(size: 36, weight: .heavyItalic)
    public static let matchTotalSectionHeader = Font.sfProText(size: 14, weight: .lightItalic)
    
    // MARK: - ShareView
    
    public static let shareViewTitle = Font.sfProDisplay(size: 36, weight: .heavyItalic)
    public static let shareViewSubTitle = Font.sfProText(size: 24, weight: .regularItalic)
    public static let shareViewHashTag = Font.notoSans(size: 14, weight: .regular)
    
    // MARK: - MyCardView
    
    public static let selectPhotoButton = Font.notoSans(size: 14, weight: .regular)
    
    // MARK: - MatchDetailView
    public static let matchDetailTitle = Font.sfProDisplay(size: 36, weight: .heavyItalic)
    public static let matchDetailSubTitle = Font.sfProDisplay(size: 24, weight: .semiboldItalic)
    public static let fieldRecordTitle = Font.sfProText(size: 20, weight: .regular)
    public static let fieldRecordMeasure = Font.sfProText(size: 32, weight: .heavyItalic)
    public static let fieldRecordUnit = Font.sfProText(size: 20, weight: .heavyItalic)
    public static let fieldRecordSquare = Font.sfProText(size: 15, weight: .heavyItalic)
    
    // MARK: - Navigation Title Style
    
    public static let navigationSportyTitle = Font.sfProText(size: 36, weight: .heavyItalic)
    public static let navigationSportySubTitle = Font.sfProText(size: 24, weight: .semiboldItalic)
    
    // MARK: - In Chart Style
    
    public static let durationStyle = Font.sfProText(size: 14, weight: .regularItalic)
    public static let maxHighlight = Font.sfProText(size: 12, weight: .semiboldItalic)
    public static let dayUnit = Font.sfProText(size: 14, weight: .lightItalic)
    public static let averageValue = Font.sfProText(size: 18, weight: .heavyItalic)
}

fileprivate extension Font {
    static func sfCompactText(size fontSize: CGFloat, weight: SFCompactText = .regular) -> Font {
        Font.custom("\(SFCompactText.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
    
    static func sfProText(size fontSize: CGFloat, weight: SFProText = .blackItalic) -> Font {
        Font.custom("\(SFProText.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
    
    static func sfProDisplay(size fontSize: CGFloat, weight: SFProDisplay = .heavyItalic) -> Font {
        Font.custom("\(SFProText.fontName)-\(weight.capitalized)",
                               size: fontSize)
    }
    
    static func notoSans(size fontSize: CGFloat, weight: NotoSans = .regular) -> Font {
        Font.custom("\(NotoSans.fontName)-\(weight.capitalized)",
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
    case lightItalic
    case regularItalic
    case semiboldItalic
    case regular
    
    var capitalized: String {
        self.rawValue.capitalized
    }
}

private enum SFProDisplay: String {
    static let fontName = String(describing: Self.self)
    
    case heavyItalic
    case semiboldItalic
    case regularItalic
    
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
