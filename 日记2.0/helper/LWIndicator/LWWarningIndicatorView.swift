//
//  LWWarningIndicatorView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/20.
//

import Foundation
import UIKit
class LWWarningIndicatorView: LWCustomIndicatorView {
   
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // 重写动画样式
    override func present() {
        indicatorView.startAnimating()
        containerView.alpha = 0
        containerView.transform = .init(translationX: 0, y: -100)
        backgroundColor = .clear
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        } completion: { (_) in}
    }
    
    // 重写动画样式
    override func dismiss() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.containerView.transform = .init(translationX: 0, y: -100)
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
}
