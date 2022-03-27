//
//  LWiCloudCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import Foundation
import UIKit

class LWiCloudCell:LWSwitchSettingCell{
    private var infoButton:UIButton!
    
    override init(delegate:LWSettingViewController,switchState:Bool,title:String,selector:Selector){
        super.init(delegate: delegate, switchState: switchState, title: title, selector: selector)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI(){
        super.initUI()
        infoButton = UIButton()
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.addTarget(self, action: #selector(infoBtnDidTapped), for: .touchUpInside)
        
        self.addSubview(infoButton)
    }
    
    override func initCons(){
        super.initCons()
        infoButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(titleLabel.snp.height)
        }
    }
    
    
    @objc func infoBtnDidTapped(){
        let vc = LWiCloudTipsViewController()
        UIApplication.getTopViewController()?.present(vc, animated: true, completion: nil)
    }
}
