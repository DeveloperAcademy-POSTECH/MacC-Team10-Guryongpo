//
//  ColorExtension.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/21.
//

import SwiftUI
 
extension Color {
    static let darkblue = Color(hex: "002737")
    static let skyblue = Color(hex: "03B3FF")
    static let hotpink = Color(hex: "FF00B8")
    static let brightmint = Color(hex: "03FFC3")
    static let titlegray = Color(hex: "8F8F8F")
}

extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}
