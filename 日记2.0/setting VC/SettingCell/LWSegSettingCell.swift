//
//  LWSegSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/30.
//  UISegmentedControl

import UIKit

class LWSegSettingCell: UIView {
    var delegate:LWSettingViewController
    var icon:UIImage?
    var title:String
    var items:[String]
    var selectedSegmentIndex:Int
    var segmentActionSelector:Selector
    private var iconImageView:UIImageView!
    private var titleLabel:UILabel!
    private var segmentedControl:UISegmentedControl!
    
    
    init(delegate:LWSettingViewController ,title:String, icon:UIImage?, controlItems:[String],selectedSegmentIndex:Int,selector:Selector) {
        self.delegate = delegate // segmentActionSelector是定义在delegate中的
        self.title = title
        self.icon = icon
        self.items = controlItems
        self.selectedSegmentIndex = selectedSegmentIndex
        self.segmentActionSelector = selector
        super.init(frame: .zero)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        iconImageView = UIImageView(image: icon)
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = LWSettingViewController.contentFont
        
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        segmentedControl.addTarget(delegate, action: segmentActionSelector, for: .valueChanged)
        
        self.addSubview(iconImageView)
        self.addSubview(titleLabel)
        self.addSubview(segmentedControl)
    }
    
    private func initCons(){
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(titleLabel.snp.height)
            if icon != nil{
                make.width.equalTo(iconImageView.snp.height)
            }else{
                make.width.equalTo(0)
            }
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(iconImageView.snp.right)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(150)
        }
    }
}
