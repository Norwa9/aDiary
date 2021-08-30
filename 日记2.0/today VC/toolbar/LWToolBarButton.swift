//
//  LWToolBarButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/30.
//

import UIKit

class LWToolBarButton: UIButton {
    var image:UIImage!{
        didSet{
            setImage(image, for: .normal)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 10
        self.backgroundColor = .tertiarySystemBackground
        self.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
    }
}
