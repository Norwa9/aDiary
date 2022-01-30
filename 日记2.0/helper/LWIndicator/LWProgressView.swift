//
//  LWProgressView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import UIKit

class LWProgressView: LWCustomIndicatorView {
    
    
    override init() {
        super.init()
    }
    
    override func initUI() {
        super.initUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setProgress(progress:Float){
        print("progress:\(progress)")
        self.progressView.setProgress(progress, animated: true)
    }
    
    override func setBaseConstrains() {
        super.setBaseConstrains()
        
//        indicatorView.snp.makeConstraints { make in
//            make.width.equalTo(label).multipliedBy(0)
//        }
        
        progressView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(10)
        }
    }
    
    override func present() {
        containerView.alpha = 0
        containerView.transform = .init(translationX: 0, y: -100)
        self.backgroundColor = .clear
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        } completion: { (_) in}
    }
    
    override func dismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.containerView.transform = .init(translationX: 0, y: -100)
            self.backgroundColor = .clear
            self.layer.borderWidth = 0
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }

}
