//
//  UserTagTableViewCell.swift
//  Face
//
//  Created by hustlzp on 16/1/21.
//  Copyright © 2016年 hustlzp. All rights reserved.
//

import UIKit
import SnapKit

class TagTableViewCell: UITableViewCell {
    private var tagView: HorizonalTagListView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        tagView = HorizonalTagListView()
        contentView.addSubview(tagView)
        
        // 约束
        
        tagView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(text: String) {
        tagView.updateTags([text])
    }
}
