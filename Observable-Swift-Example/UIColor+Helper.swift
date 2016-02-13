//
//  UIColor+Helper.swift
//  Observable-Swift-Example
//
//  Created by hustlzp on 16/2/13.
//  Copyright © 2016年 hustlzp. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexValue: Int64) {
        self.init(red: (CGFloat)((hexValue >> 24) & 0xFF) / 255.0, green: (CGFloat)((hexValue >> 16) & 0xFF) / 255.0, blue: (CGFloat)((hexValue >> 8) & 0xFF) / 255.0, alpha: (CGFloat)((hexValue) & 0xFF) / 255.0)
    }
    
    func lighter(percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: min(b * (1 + percentage), 1), alpha: a)
    }
    
    func darker(percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: min(b * (1 - percentage), 1), alpha: a)
    }
}
