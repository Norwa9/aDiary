//
//  LWFontPickerButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/5.
//

import Foundation
import UIKit

enum FontPlace:Int{
    case monthCell // 主页的字体
    case diary // 日记的字体
}

class LWFontPickerButton:UIView{
    private var fontNameLabel:UILabel!
    var fontPlace:FontPlace!
    
    
    init(delegate:LWSettingViewController,actionSelector:Selector,fontPlace:FontPlace) {
        super.init(frame: .zero)
        let tapGes = UITapGestureRecognizer(target: delegate, action: actionSelector)
        self.addGestureRecognizer(tapGes)
        self.fontPlace = fontPlace
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
        if fontPlace == .diary{
            fontNameLabel.text = userDefaultManager.fontName ?? "苹方"
            fontNameLabel.font = userDefaultManager.customFont(withSize: 16)
        }else{
            fontNameLabel.text = userDefaultManager.monthCellFontName ?? "DIN Alternate"
            fontNameLabel.font = userDefaultManager.customMonthCellFont(withSize: 16)
        }
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
        if fontPlace == .diary{
            fontNameLabel.text = userDefaultManager.fontName ?? "苹方"
            fontNameLabel.font = userDefaultManager.customFont(withSize: 16)
        }else{
            fontNameLabel.text = userDefaultManager.monthCellFontName ?? "DIN Alternate"
            fontNameLabel.font = userDefaultManager.customMonthCellFont(withSize: 16)
        }
        fontNameLabel.adjustsFontSizeToFitWidth = true
        layoutIfNeeded()
    }
}
