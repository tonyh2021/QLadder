//
//  UIView+Color.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/28.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import UIKit

extension UIColor {
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

//use
//let swiftColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
//if let rgb = swiftColor.rgb() {
//    print(rgb)
//} else {
//    print("conversion failed")
//}

