//
//  LWiCloudTipsViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import UIKit

class LWTipsViewController: LWBaseCardViewController {
    var content:String
    var contentTextView:UITextView!
    var confirmButton:UIButton!
    
    let confirmTitle = NSAttributedString(string: "确定").addingAttributes([
        .font : UIFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor : UIColor.white
    ])
    
    
    init(cardViewHeight: CGFloat, cardTitle: String, content:String) {
        self.content = content
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
        let tip = self.content
        
        let tipAT = NSMutableAttributedString(string: tip).addingAttributes([
            .paragraphStyle : para,
            .font : UIFont.systemFont(ofSize: 16),
            .foregroundColor : UIColor.label
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
