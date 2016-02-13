//
//  ViewController.swift
//  Observable-Swift-Example
//
//  Created by hustlzp on 16/2/13.
//  Copyright © 2016年 hustlzp. All rights reserved.
//

import UIKit
import Observable
import SnapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeletionDetectableTextFieldDelegate {

    private let reuseIdentifier = "reuseIdentifier"
    private var tableView: UITableView!
    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var textField: DeletionDetectableTextField!
    private var userTagsView: HorizonalTagListView!
    private var matchedTags = [String]()
    
    private var tags = Observable([String]())
    private var prepareRemoveTag = Observable(false)
    
    private var textFieldDidChangeEvent = EventReference<String>()
    private var textFieldWillDeleteEvent = EventReference<String>()
    
    // MARK: Lifecycle
    
    // MARK: View Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        
        let topBar = createTopBar()
        view.addSubview(topBar)
        
        let tipView = createTipView()
        view.addSubview(tipView)
        
        tableView = UITableView()
        tableView.hidden = true
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.registerClass(TagTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        
        // 约束
        
        topBar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view).offset(64)
            make.left.right.equalTo(view)
            make.height.equalTo(50)
        }
        
        tipView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topBar.snp_bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topBar.snp_bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: "finish")
        rightButton.enabled = false
        
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "添加城市"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        textFieldDidChangeEvent += { (_) in
            if !self.isNilOrEmpty(self.textField.text) {
                self.prepareRemoveTag <- false
            }
            
            self.matchedTags = Constant.cities.filter { return $0.rangeOfString(self.textField.text!) != nil }
            self.tableView.reloadData()
            
            self.updateTableViewVisibility()
            self.updateFinishButtonEnable()
        }
        
        prepareRemoveTag.afterChange += { (_) in
            if self.prepareRemoveTag^ {
                self.userTagsView.prepareRemoveTag(self.tags^.count - 1)
            } else {
                self.userTagsView.cancelPrepareRemoveTag()
            }
            
            self.updateFinishButtonEnable()
        }
        
        tags.afterChange += { (_) in
            // TextField placeholder
            if self.tags^.count == 0 {
                self.textField.placeholder = "输入城市名称..."
            } else if self.tags^.count >= 3 {
                self.textField.placeholder = ""
            } else {
                self.textField.placeholder = "最多三个"
            }
            
            // TextField left constraint
            self.textField.snp_updateConstraints { (make) -> Void in
                if self.tags^.count == 0 {
                    make.left.equalTo(self.userTagsView.snp_right)
                } else {
                    make.left.equalTo(self.userTagsView.snp_right).offset(8)
                }
            }
            
            // TextField text
            self.textField.text = ""
            self.textFieldDidChangeEvent.notify("")
            
            // Update tagsView
            self.userTagsView.updateTags(self.tags^)
            
            // scrollView滑动到最右边
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
            if self.scrollView.contentSize.width > self.scrollView.bounds.size.width {
                let bottomOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
            
            self.updateTableViewVisibility()
            self.updateFinishButtonEnable()
        }
        
        textFieldWillDeleteEvent += { (_) in
            if !self.isNilOrEmpty(self.textField.text) || self.tags^.count == 0 {
                return
            }
            
            if self.prepareRemoveTag^ {
                self.prepareRemoveTag <- false
                self.tags.value.removeLast()
            } else {
                self.prepareRemoveTag <- true
            }
        }
        
        textField.becomeFirstResponder()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Public Methods
    
    // MARK: User Interaction
    
    @objc private func finish() {
        showAlert("完成")
    }
    
    @objc private func textFieldDidChanged() {
        textFieldDidChangeEvent.notify("")
    }
    
    // MARK: Notification Handles
    
    func keyboardWillShow(notification: NSNotification) {
        let kbSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
        
        tableView.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(view).offset(-kbSize!.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(view)
        }
    }
    
    // MARK: DeletionDetectableTextFieldDelegate
    
    func textFieldWillDelete() {
        textFieldWillDeleteEvent.notify("")
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tags^.count == 3 {
            return 0
        } else {
            return matchedTags.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let city = matchedTags[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TagTableViewCell
        cell.update(city)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var tag = ""
        
        if tags^.count == 3 {
            showAlert("最多添加3个标签")
            return
        }
        
        // 添加标签
        if indexPath.row < matchedTags.count {
            tag = matchedTags[indexPath.row]
        } else if indexPath.row == matchedTags.count {
            tag = textField.text!
        }
        
        if tag.isEmpty {
            showAlert("标签不能为空")
            return
        }
        
        if tags^.indexOf(tag) != nil {
            showAlert("该标签已存在")
            return
        }
        
        tags.value.append(tag)
    }
    
    // MARK: View Helpers
    
    private func createTopBar() -> UIView {
        let topBar = UIView()
        
        scrollView = createScrollView()
        automaticallyAdjustsScrollViewInsets = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        topBar.addSubview(scrollView)
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor(hexValue: 0xBBBBBBFF)
        topBar.addSubview(bottomBorder)
        
        // 约束
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(topBar)
        }
        
        scrollContentView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(topBar)
        }
        
        bottomBorder.snp_makeConstraints { (make) -> Void in
            make.left.bottom.right.equalTo(topBar)
            make.height.equalTo(0.5)
        }
        
        return topBar
    }
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollContentView = UIView()
        scrollView.addSubview(scrollContentView)
        
        userTagsView = HorizonalTagListView()
        scrollContentView.addSubview(userTagsView)
        
        textField = DeletionDetectableTextField()
        textField.returnKeyType = .Default
        textField.deletionDetectableDelegate = self
        textField.placeholder = "输入城市名称..."
        textField.font = UIFont.systemFontOfSize(14)
        textField.addTarget(self, action: "textFieldDidChanged", forControlEvents: .EditingChanged)
        scrollContentView.addSubview(textField)
        
        // 约束
        
        scrollContentView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(scrollView)
        }
        
        userTagsView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(scrollContentView)
            make.left.equalTo(scrollContentView)
        }
        
        textField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(userTagsView.snp_right)
            make.width.greaterThanOrEqualTo(120)
            make.centerY.equalTo(scrollContentView)
            make.right.equalTo(scrollContentView)
        }
        
        return scrollView
    }
    
    private func createTipView() -> UIView {
        let tipView = UIView()
        tipView.backgroundColor = UIColor(hexValue: 0xF9F9F9FF)
        
        let tipLabel = UILabel()
        tipLabel.textColor = UIColor.lightGrayColor()
        tipLabel.text = "添加城市，最多不超过三个"
        tipLabel.font = UIFont.systemFontOfSize(15)
        tipView.addSubview(tipLabel)
        
        tipLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(tipView)
            make.top.equalTo(tipView).offset(40)
        }
        
        return tipView
    }
    
    // MARK: Internal Helpers
    
    private func updateTableViewVisibility() {
        if tags^.count == 0 && isNilOrEmpty(textField.text) {
            tableView.hidden = true
        } else {
            tableView.hidden = false
        }
    }
    
    private func updateFinishButtonEnable() {
        if tags^.count > 0 && isNilOrEmpty(textField.text) && !prepareRemoveTag^ {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }

    private func isNilOrEmpty(string: String?) -> Bool {
        if let string = string {
            return string.isEmpty
        } else {
            return true
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "确认", style: .Default, handler: nil)
        alert.addAction(confirmAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}


