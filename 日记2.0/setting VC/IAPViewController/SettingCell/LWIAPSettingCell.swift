//
//  LWIAPSettingCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/31.
//

import UIKit

class LWIAPSettingCell: UIView {
    var delegate:LWSettingViewController
    var title:String
    var actionSelector:Selector
    private var containerView:UIView!
    private var button:UIButton!
    private var titleLabel:UILabel!
    
    init(delegate:LWSettingViewController,selector:Selector) {
        self.delegate = delegate // segmentActionSelector是定义在delegate中的
        self.title = "aDiary Pro"
        self.actionSelector = selector
        super.init(frame: .zero)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.setupShadow()
        self.backgroundColor = settingContainerDynamicColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = false
        
        containerView = UIView()
        containerView.backgroundColor = settingContainerDynamicColor
        containerView.layer.cornerRadius = 10
        
        button = UIButton()
        updatePurchasedButton()
        button.contentHorizontalAlignment = .center
        button.backgroundColor = UIColor.colorWithHex(hexColor: 0xFFD700).withAlphaComponent(0.1)
        button.layer.borderColor = UIColor.colorWithHex(hexColor: 0xFFD700).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.addTarget(delegate, action: actionSelector, for: .touchUpInside)
        
        
        titleLabel = UILabel()
        titleLabel.font = LWSettingViewController.titleFont
        titleLabel.text = self.title
        
        
        self.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(button)
    }
    
    public func updatePurchasedButton(){
        var upgradeText:String
        let edition = userDefaultManager.purchaseEdition
        if edition == .freeTrial || edition == .notPurchased{ // 如果是试用或未购买
            upgradeText = "升级"
        }else{
            upgradeText = "Pro"
        }
        let upgradeAttrText = NSAttributedString(string: upgradeText).addingAttributes([
            .font : LWSettingViewController.titleFont,
            .foregroundColor : UIColor.colorWithHex(hexColor: 0xFFD700)
        ])
        button.setAttributedTitle(upgradeAttrText, for: .normal)
    }
    
    
    private func initCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerY.equalToSuperview()
        }
    }

}
