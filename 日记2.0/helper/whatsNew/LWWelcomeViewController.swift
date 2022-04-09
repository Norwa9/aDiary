//
//  LWWelcomeViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/4/9.
//

import UIKit

class LWWelcomeViewController: UIViewController {
    var iconImageView:UIImageView!
    var headTitle:UILabel!
    var subTitle:UILabel!
    var enterButton:UIButton!
    let enterTitle = NSAttributedString(string: "继续").addingAttributes([
        .font : UIFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor : UIColor.white
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setCons()
        
    }
    

    func initUI(){
        self.view.backgroundColor = .systemBackground
        
        iconImageView = UIImageView(image: UIImage(named: "icon_roundCornor"))
        
        headTitle = UILabel()
        headTitle.numberOfLines = 0
        headTitle.text = """
        欢迎使用
        aDiary
        """
        headTitle.font = UIFont.boldSystemFont(ofSize: 30)
        
        subTitle = UILabel()
        subTitle.text = "轻松记录图文日记以及待办事项"
        subTitle.font = UIFont.systemFont(ofSize: 16)
        
        enterButton = UIButton()
        enterButton.addTarget(self, action: #selector(enter), for: .touchUpInside)
        enterButton.backgroundColor = .black
        enterButton.layer.cornerRadius = 10
        enterButton.setAttributedTitle(enterTitle, for: .normal)
        
        self.view.addSubview(iconImageView)
        self.view.addSubview(headTitle)
        self.view.addSubview(subTitle)
        self.view.addSubview(enterButton)
        
    }
    
    func setCons(){
        self.iconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(headTitle.snp.top).offset(-5)
            make.left.equalTo(headTitle)
            make.size.equalTo(CGSize(width: 70, height: 70))
        }
        
        self.headTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.centerY.equalToSuperview().offset(-30)
        }
        self.subTitle.snp.makeConstraints { make in
            make.top.equalTo(headTitle.snp.bottom).offset(5)
            make.left.equalTo(headTitle)
        }
        
        self.enterButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 150, height: 60))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    @objc func enter(){
        self.dismiss(animated: true, completion: nil)
    }
}
