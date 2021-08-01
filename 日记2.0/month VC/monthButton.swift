//
//  monthButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit

class monthButton: UIButton {
    var hasSelected:Bool = false
    var monthLabel:UILabel = UILabel()
    var containView:UIView = UIView()
    
    weak var monthVC:monthVC!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    func configureUI(){
        //圆形
        self.setupShadow(opacity: 1, radius: 1, offset: CGSize(width: 1, height: 0), color: UIColor.black.withAlphaComponent(0.35))
        
        //containView
        self.addSubview(containView)
        containView.fillSuperview()
        containView.layer.cornerRadius = self.frame.width/2
        containView.isUserInteractionEnabled = false
        containView.backgroundColor = .white
        
        //monthLabel
        containView.addSubview(monthLabel)
        monthLabel.font = UIFont.appMonthButtonFont()
        monthLabel.fillSuperview()
        monthLabel.textAlignment = .center
        monthLabel.textColor = .black
    }
    
    func animateBackgroundColor(){
        if !hasSelected{
            hasSelected = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.containView.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
                self.monthLabel.textColor = .white
            } completion: { (_) in
                
            }
        }else{
            hasSelected = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.containView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.monthLabel.textColor = .black
            } completion: { (_) in
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
