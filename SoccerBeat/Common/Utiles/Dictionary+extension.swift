//
//  Dictionary+extension.swift
//  SoccerBeat
//
//  Created by Gucci on 3/20/24.
//

import Foundation

extension Dictionary where Key == String {
    // dictionary를 안전하게 옵셔널 언래핑하기 위한 메서드
    func getValue<T>(forKey key: String) -> T? {
        return self[key] as? T
    }
}
