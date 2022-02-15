//
//  LWSwitchSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/15.
//

import Foundation
import UIKit

class LWSwitchSettingCell:UIView{
    var delegate:LWSettingViewController
    var title:String
    var switchState:Bool
    var actionSelector:Selector
    private var titleLabel:UILabel!
    private var switcher:UISwitch!
    
    init(delegate:LWSettingViewController,switchState:Bool,title:String,selector:Selector) {
        self.delegate = delegate // segmentActionSelector是定义在delegate中的
        self.title = title
        self.actionSelector = selector
        self.switchState = switchState
        super.init(frame: .zero)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = LWSettingViewController.contentFont
        
        switcher = UISwitch()
        switcher.isOn = switchState
        switcher.addTarget(delegate, action: self.actionSelector, for: .valueChanged)
        
        self.addSubview(titleLabel)
        self.addSubview(switcher)
    }
    
    private func initCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        switcher.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
    }
}
