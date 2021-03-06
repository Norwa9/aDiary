//
//  monthButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/2.
//

import UIKit

class monthButton: UIButton {
    static let monthButtonDiameter:CGFloat = 25
    var hasSelected:Bool = false
    var monthLabel:UILabel = UILabel()
    var containView:UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    func configureUI(){
        //圆形
        self.setupShadow(opacity: 0.7, radius: 1, offset: .zero, color: .black.withAlphaComponent(0.3))
        
        //containView
        self.addSubview(containView)
        containView.fillSuperview()
        containView.layer.cornerRadius = monthButton.monthButtonDiameter / 2.0
        containView.isUserInteractionEnabled = false
        containView.backgroundColor = .tertiarySystemBackground
        
        //monthLabel
        containView.addSubview(monthLabel)
        monthLabel.font = userDefaultManager.monthButtonFont
        monthLabel.textColor = .label
        monthLabel.fillSuperview()
        monthLabel.textAlignment = .center
    }
    
    func animateBackgroundColor(){
        LWImpactFeedbackGenerator.impactOccurred(style: .light)
        self.showBounceAnimation {}
        if !hasSelected{
            hasSelected = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.containView.backgroundColor = APP_GREEN_COLOR()
                self.monthLabel.textColor = .white
            } completion: { (_) in
                
            }
        }else{
            hasSelected = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.containView.backgroundColor = .tertiarySystemBackground
                self.monthLabel.textColor = .label
            } completion: { (_) in
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
