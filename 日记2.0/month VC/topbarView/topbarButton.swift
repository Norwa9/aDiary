//
//  topbarButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class topbarButton: UIButton {
    var image:UIImage!{
        didSet{
            buttonImageView.image = image
        }
    }
    var islike:Bool = false{
        didSet{
            AnimatelikeImage()
        }
    }

    var buttonImageView:UIImageView!
    var holderView:UIView!
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraint()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraint()
    }

    func setupUI(){
        //holderView
        holderView = UIView()
        holderView.isUserInteractionEnabled = false//为什么不设置为false按钮不能响应点击？
        holderView.backgroundColor = .white
        holderView.layer.cornerRadius = 10
        holderView.setupShadow(opacity: 0.35, radius: 2, offset:.zero, color: .black)
        addSubview(holderView)
        
        //button image view
        buttonImageView = UIImageView()
        buttonImageView.contentMode = .scaleAspectFill
        holderView.addSubview(buttonImageView)
        
    }
    
    func setupConstraint(){
        holderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        
    }
    
    func AnimatelikeImage(){
        if !islike {
            image = UIImage(named: "star1")
        }else{
            image = UIImage(named: "star2")
        }
    }

    func switchLayoutModeIcon(){
        let columnNumber = layoutParasManager.shared.collectioncolumnNumber
        switch columnNumber {
        case 1:
            image = UIImage(named: "waterfallmode")
        case 2:
            image = UIImage(named: "listmode")
        default:
            return
        }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
