//
//  LWiCloudTipsViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import UIKit

class LWiCloudTipsViewController: LWBaseCardViewController {
    var contentTextView:UITextView!
    var confirmButton:UIButton!
    
    let confirmTitle = NSAttributedString(string: "确定").addingAttributes([
        .font : UIFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor : UIColor.white
    ])
    
    
    override init(cardViewHeight: CGFloat, cardTitle: String) {
        super.init(cardViewHeight: cardViewHeight, cardTitle: cardTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 不可再initUI
        
    }
    
    override func initUI(){
        super.initUI()
        contentTextView = UITextView()
        contentTextView.attributedText = getAttributedContent()
        contentTextView.isEditable = false
        
        confirmButton = UIButton()
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmButton.backgroundColor = .black
        confirmButton.layer.cornerRadius = 10
        confirmButton.setAttributedTitle(confirmTitle, for: .normal)
        
        
        self.view.addSubview(contentTextView)
        self.view.addSubview(confirmButton)
    }
    
    func getAttributedContent() -> NSAttributedString{
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 5
        let tip = """
        开启后：
        1. 可在多设备间同步：一个设备做出的修改能够实时同步到其他设备。
        2. 可生成云端备份：云端将会保持一份与本地相同的数据，App卸载重装后能够从云端恢复。
        
        注意：
        请确保在系统设置中已启用iCloud，并有足够的iCloud存储空间。
        """
        
        let tipAT = NSMutableAttributedString(string: tip).addingAttributes([
            .paragraphStyle : para,
            .font : UIFont.systemFont(ofSize: 16),
        ])
        
        
        return tipAT
    }
    
    override func setCons(){
        super.setCons()
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(confirmButton.snp.top).offset(-10)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    @objc func confirm(){
        self.dismiss(animated: true, completion: nil)
    }
    

}
