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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setupUI(){
//        self.layer.borderWidth = 3
        //holderView
        holderView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        holderView.isUserInteractionEnabled = false//为什么不设置为false按钮不能响应点击？
        holderView.backgroundColor = .white
        holderView.layer.cornerRadius = 10
        holderView.setupShadow(opacity: 0.35, radius: 2, offset:.zero, color: .black)
        addSubview(holderView)
        
        //button image view
        let size = self.frame.size
        let pedding:CGFloat = 1
        buttonImageView = UIImageView(frame: CGRect(x: pedding, y: pedding, width: size.width - 2 * pedding, height: size.height - 2 * pedding))
        buttonImageView.contentMode = .scaleAspectFill
        holderView.addSubview(buttonImageView)
        
        
        
    }
    
    func AnimatelikeImage(){
        if !islike {
            image = UIImage(named: "star1")
        }else{
            image = UIImage(named: "star2")
        }
    }




    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
