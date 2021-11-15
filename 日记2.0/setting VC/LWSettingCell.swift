//
//  LWSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/11/15.
//

import Foundation
import UIKit

enum settingCellType:Int{
    case switcher // 开关设置
    case actionButton // 按钮跳转设置
}
class LWSettingCell:UIView{
    var delegate:LWSettingViewController!
    // 标题
    var titleView:UIView!
    // 图标或者其他可点击view
    var accessoryIcon:UIView! // UIImageView or UISwitch
    
    var text:String!
    var accessoryImage:UIImage?
    var titleActionSelector:Selector? // 标题的动作
    var accessoryActionSelector:Selector? // 附属视图的动作
    
    init(text:String, accessoryImage:UIImage?,actionSelector:Selector?,accessoryActionSelector:Selector?) {
        super.init(frame: .zero)
        self.text = text
        self.accessoryImage = accessoryImage
        self.titleActionSelector = actionSelector
        self.accessoryActionSelector = accessoryActionSelector
        
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        if let titleActionSelector = titleActionSelector {
            titleView = UIButton()
            if let titleButton = titleView as? UIButton{
                let attributes:[NSAttributedString.Key : Any] = [
                    .font : UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor : UIColor.label
                ]
                let attributedTitle = NSMutableAttributedString(string: self.text,attributes: attributes)
                titleButton.setAttributedTitle(attributedTitle, for: .normal)
                titleButton.addTarget(delegate, action: titleActionSelector, for: .touchUpInside)
            }
        }else{
            titleView = UILabel()
            if let titleLabel = titleView as? UILabel{
                titleLabel.text = self.text
                titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
            }
        }
        
        if let accessoryActionSelector = accessoryActionSelector{
            // switcher等其他情况
            accessoryIcon = UIView()
            
        }else{
            accessoryIcon =  UIImageView()
            if let accessoryIcon = accessoryIcon as? UIImageView{
                accessoryIcon.image = self.accessoryImage
            }
        }
        
        self.addSubview(titleView)
        self.addSubview(accessoryIcon)
    }
    
    func setupCons(){
        titleView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
        }
        
        accessoryIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview()
        }
    }
}
