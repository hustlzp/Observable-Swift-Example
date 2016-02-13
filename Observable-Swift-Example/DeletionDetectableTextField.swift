//
//  DeletionDetactableTextField.swift
//  Face
//
//  Created by hustlzp on 16/1/24.
//  Copyright © 2016年 hustlzp. All rights reserved.
//

import UIKit

@objc protocol DeletionDetectableTextFieldDelegate: class {
    optional func textFieldWillDelete()
    optional func textFieldDidDelete()
}

class DeletionDetectableTextField: UITextField {

    weak var deletionDetectableDelegate: DeletionDetectableTextFieldDelegate?
    
    override func deleteBackward() {
        deletionDetectableDelegate?.textFieldWillDelete?()
        
        super.deleteBackward()

        deletionDetectableDelegate?.textFieldDidDelete?()
    }

}
