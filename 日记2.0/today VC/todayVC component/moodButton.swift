//
//  moodButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit

class moodButton: UIButton {
    var hasSelected:Bool = false
    var moodType:moodTypes!{
        didSet{
            buttonImageView.image = UIImage(named: moodType.rawValue)
        }
    }
    var holderView:UIView!
    var holderViewOriginCenter:CGPoint!

    var buttonImageView:UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func didMoveToSuperview() {
        holderViewOriginCenter = holderView.center
    }

    func setupUI(){
        //holderView
        holderView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        holderView.isUserInteractionEnabled = false//为什么不设置为false按钮不能响应点击？
        holderView.backgroundColor = .white
        holderView.layer.cornerRadius = 10
        holderView.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        addSubview(holderView)
        
        //button
        buttonImageView = UIImageView()
        buttonImageView.frame = CGRect(origin: .zero, size: frame.size)
        buttonImageView.contentMode = .scaleAspectFill
        holderView.addSubview(buttonImageView)
    }
    
    func animateSelectedView(duration:TimeInterval = 0.2){
        if hasSelected{
            hasSelected = false
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.holderView.transform = .identity
                self.holderView.backgroundColor = .white
            } completion: { (_) in
                
            }
        }else{
            hasSelected = true
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.holderView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.holderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            } completion: { (_) in
                
            }
        }
    }
    
    




    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
