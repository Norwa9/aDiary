//
//  LWBaseSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import Foundation
import UIKit

class LWBaseSettingCell:UIView{
    var delegate:LWSettingViewController
    var title:String
    
    var titleActionSelector:Selector? // 标题的动作
    var accessoryActionSelector:Selector? // 附属视图的动作
    
    private var titleLabel:UILabel!
    
    init(delegate:LWSettingViewController,title:String) {
        self.delegate = delegate
        self.title = title
        super.init(frame: .zero)
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = LWSettingViewController.contentFont
        
        
        
        
        self.addSubview(titleLabel)
    }
    
    func setupCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
    }
}
