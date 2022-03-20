//
//  LWRecodingButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit

class LWRecodingButton:UIView{
    var buttonTitleLabel:UILabel!
    var colorMaskView:UIView!
    
    
    init() {
        super.init(frame: .zero)
        
        initUI()
        setupCons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI(){
        self.layer.cornerRadius = 15
        self.addBorder(width: 2, color: .black)
        
        buttonTitleLabel = UILabel()
        buttonTitleLabel.attributedText = NSAttributedString(string: "开始").addingAttributes([
            .font : UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor : UIColor.label
        ])
        buttonTitleLabel.textAlignment = .center
        
        colorMaskView = UIView()
        colorMaskView.layer.cornerRadius = 15
        colorMaskView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        colorMaskView.alpha = 0
        
        
        self.addSubview(buttonTitleLabel)
        self.addSubview(colorMaskView)
        
        
        
    }

    func setupCons(){
        buttonTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        colorMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
        
    }
    
    /// 开始或暂停录音的动画
    func recordAnimation(isRecording:Bool){
        if isRecording{
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut]) {
                self.buttonTitleLabel.attributedText = NSAttributedString(string: "暂停").addingAttributes([
                    .font : UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor : UIColor.label
                ])
                self.addBorder(width: 2, color: .black)
            } completion: { _ in}
            
        }else{
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut]) {
                self.buttonTitleLabel.attributedText = NSAttributedString(string: "继续").addingAttributes([
                    .font : UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor : UIColor.red
                ])
                self.addBorder(width: 2, color: .red)
            } completion: { _ in}

            
        }
    }
}



