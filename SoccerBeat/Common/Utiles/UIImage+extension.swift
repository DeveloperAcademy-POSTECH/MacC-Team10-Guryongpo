//
//  UIImage+extension.swift
//  SoccerBeat
//
//  Created by jose Yun on 8/6/24.
//

import SwiftUI

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        self.draw(in: CGRect(origin: CGPoint.zero, size: size))

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
