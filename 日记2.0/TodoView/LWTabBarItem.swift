//
//  LWTabBarItem.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/11.
//

import UIKit

class LWTabBarItem: UIView {
    var isSelected:Bool = false{
        didSet{
            changeSelectedView()
        }
    }
    private var imageView:UIImageView!
    private var titleLabel:UILabel!
    private var selectedPromptView:UIView!
    private var imageName:String!
    private var title:String!
    
    init(title:String,imageName:String) {
        super.init(frame: .zero)
        self.imageName = imageName
        self.title = title
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
//        self.setDebugBorder()
        //self.layer.cornerRadius = 5
        //self.clipsToBounds = true
        
        selectedPromptView = UIView()
        selectedPromptView.layer.cornerRadius = 10
        selectedPromptView.addBorder(width: 1, color: UIColor.systemGray6)
        selectedPromptView.backgroundColor = fontPickerButtonDynamicColor
        selectedPromptView.alpha = 0
        
        imageView = UIImageView(image: UIImage(named: self.imageName))
        imageView.contentMode = .scaleAspectFill
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "DIN Alternate", size: 12)!
        titleLabel.adjustsFontSizeToFitWidth = true
        
        self.addSubview(selectedPromptView)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        
    }
    
    private func setCons(){
        self.selectedPromptView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(self.snp.height).multipliedBy(1.2)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.width.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    private func changeSelectedView(){
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
            if self.isSelected{
//                self.backgroundColor = .systemGray6
//                self.addBorder(width: 1, color: .lightGray)
                self.selectedPromptView.alpha = 1
            }else{
//                self.backgroundColor = .clear
//                self.layer.borderWidth = 0
                self.selectedPromptView.alpha = 0
            }
        } completion: { _ in
            
        }

    }

}
