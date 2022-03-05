//
//  LWFontPickerButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/5.
//

import Foundation
import UIKit

class LWFontPickerButton:UIView{
    private var fontNameLabel:UILabel!
    
    
    init(delegate:LWSettingViewController,actionSelector:Selector) {
        super.init(frame: .zero)
        let tapGes = UITapGestureRecognizer(target: delegate, action: actionSelector)
        self.addGestureRecognizer(tapGes)
        
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initUI(){
        self.layer.cornerRadius = 7
        self.backgroundColor = fontPickerButtonDynamicColor
        
        fontNameLabel = UILabel()
        fontNameLabel.text = userDefaultManager.fontName ?? "苹方"
        fontNameLabel.font = userDefaultManager.customFont(withSize: 16)
        fontNameLabel.adjustsFontSizeToFitWidth = true
        fontNameLabel.textColor = .label
        
        self.addSubview(fontNameLabel)
    }
    
    private func setCons(){
        fontNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    public func updateFontLabel(){
        fontNameLabel.text = userDefaultManager.fontName ?? "苹方"
        fontNameLabel.font = userDefaultManager.customFont(withSize: 16)
        fontNameLabel.adjustsFontSizeToFitWidth = true
        layoutIfNeeded()
    }
}
