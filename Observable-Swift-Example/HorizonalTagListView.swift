//
//  HorizonalTagListView.swift
//  Face
//
//  Created by hustlzp on 16/1/21.
//  Copyright © 2016年 hustlzp. All rights reserved.
//

import UIKit

class HorizonalTagListView: UIView {

    var cornerRadius: CGFloat = 13.0
    var textColor = UIColor(hexValue: 0x808393FF)
    var selectedTextColor = UIColor(hexValue: 0x808393FF)
    var paddingX: CGFloat = 9.5
    var paddingY: CGFloat = 5.5
    var tagBackgroundColor = UIColor(hexValue: 0xF3F3F9FF)
    var tagSelectedBackgroundColor = UIColor(hexValue: 0xF3F3F9FF).darker(0.1)
    var textFont = UIFont.systemFontOfSize(13.5)
    var marginX: CGFloat = 8.0
    
    private var tagViews = [TagView]()
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    func addTag(title: String) -> TagView {
        let tagView = TagView(title: title)
        
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.tagSelectedBackgroundColor = tagSelectedBackgroundColor
        tagView.cornerRadius = cornerRadius
        tagView.paddingY = paddingY
        tagView.paddingX = paddingX
        tagView.textFont = textFont
        
        tagViews.append(tagView)
        
        rearrangeViews()
        
        return tagView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    // Public Methods
    
    func updateTags(tags: [String]) {
        removeAllTags()
        tags.forEach { addTag($0) }
    }
    
    func removeAllTags() {
        for tagView in tagViews {
            tagView.removeFromSuperview()
        }
        
        tagViews.removeAll()
        
        rearrangeViews()
    }
    
    func removeTag(index: Int) {
        if index < 0 || index > tagViews.count {
            return
        }
        
        tagViews[index].removeFromSuperview()
        tagViews.removeAtIndex(index)
        
        rearrangeViews()
    }
    
    func prepareRemoveTag(index: Int) {
        if index < 0 || index > tagViews.count {
            return
        }
        
        tagViews[index].backgroundColor = tagSelectedBackgroundColor
    }
    
    func cancelPrepareRemoveTag() {
        for tagView in tagViews {
            tagView.backgroundColor = tagBackgroundColor
        }
    }
    
    // Internal Helpers
    
    private func rearrangeViews() {
        width = 0
        height = 0
        
        for tagView in tagViews {
            tagView.removeFromSuperview()
        }
        
        for tagView in tagViews {
            let tagViewWidth = tagView.intrinsicContentSize().width
            let tagViewHeight = tagView.intrinsicContentSize().height

            var tagViewX: CGFloat
            if width == 0 {
                tagViewX = 0
            } else {
                tagViewX = width + marginX
            }
            
            tagView.frame = CGRectMake(tagViewX, 0, tagViewWidth, tagViewHeight)
            addSubview(tagView)
            
            if tagViewHeight > height {
                height = tagViewHeight
            }
            width = tagViewX + tagViewWidth
        }
        
        invalidateIntrinsicContentSize()
    }
}
