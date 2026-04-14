//
//  Backport+extension.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 4/15/24.
//

import SwiftUI

public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { Backport(self) }
}

extension Backport where Content: View {
    @ViewBuilder func defaultScrollAnchor(_ anchor: UnitPoint?) -> some View {
        if #available(iOS 17, *) {
            content.defaultScrollAnchor(anchor)
        } else {
            content
        }
    }
}
