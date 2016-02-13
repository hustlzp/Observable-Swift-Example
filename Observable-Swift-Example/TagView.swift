//
//  TagView.swift
//  duowen
//
//  Created by hustlzp on 15/12/19.
//  Copyright © 2015年 hustlzp. All rights reserved.
//

import UIKit

class TagView: UIButton {

    var cornerRadius: CGFloat = 13.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    var textColor = UIColor(hexValue: 0x808393FF) {
        didSet {
            setTitleColor(textColor, forState: .Normal)
        }
    }
    
    var selectedTextColor = UIColor.blackColor()
    
    var paddingX: CGFloat = 9.5 {
        didSet {
            contentEdgeInsets.left = paddingX
            contentEdgeInsets.right = paddingX
        }
    }
    
    var paddingY: CGFloat = 5.5 {
        didSet {
            contentEdgeInsets.top = paddingY
            contentEdgeInsets.bottom = paddingY
        }
    }
    
    var tagBackgroundColor = UIColor(hexValue: 0xF3F3F9FF) {
        didSet {
            backgroundColor = tagBackgroundColor
        }
    }
    
    var tagSelectedBackgroundColor = UIColor(hexValue: 0xF3F3F9FF).darker(0.1)
    
    var textFont = UIFont.systemFontOfSize(13.5) {
        didSet {
            titleLabel?.font = textFont
        }
    }
    
    // MARK: Life Cycle
    
    init(title: String? = nil) {
        super.init(frame: CGRect.zero)
        
        userInteractionEnabled = false
        setTitle(title, forState: .Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: User Interface
    
    // MARK: Public Methods
    
    func update(text: String){
        setTitle(text, forState: .Normal)
    }
}
