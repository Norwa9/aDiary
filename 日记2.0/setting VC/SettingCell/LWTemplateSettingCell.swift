//
//  LWTemplateSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import Foundation
import UIKit

class LWTemplateSettingCell:UIView{
    var delegate:LWSettingViewController
    var title:String
    
    var actionSelector:Selector
    private var actionButton:UIView!
    private var titleLabel:UILabel!
    private var switcher:UISwitch!
    
    init(delegate:LWSettingViewController,title:String,selector:Selector) {
        self.delegate = delegate // segmentActionSelector是定义在delegate中的
        self.title = title
        self.actionSelector = selector
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
        
        actionButton = createActionButton()
        
        self.addSubview(titleLabel)
        self.addSubview(actionButton)
    }
    
    private func initCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
    }
    
    private func createActionButton()->UIView{
        let view = UIView()
        view.layer.cornerRadius = 7
        view.backgroundColor = fontPickerButtonDynamicColor
        
        let Label = UILabel()
        Label.text = "管理模板"
        Label.font = UIFont.systemFont(ofSize: 14)
        Label.adjustsFontSizeToFitWidth = true
        Label.textColor = .label
        
        let tapGes = UITapGestureRecognizer(target: delegate, action: actionSelector)
        view.addGestureRecognizer(tapGes)
        
        
        view.addSubview(Label)
        
        Label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        return view
    }
}
