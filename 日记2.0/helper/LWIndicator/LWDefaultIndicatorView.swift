//
//  LWDefaultIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit

class LWDefaultIndicatorView: LWCustomIndicatorView {
   
    
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
        containerView.layer.borderWidth = 0
        backgroundColor = .clear
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
            self.containerView.layer.borderWidth = 1
        } completion: { (_) in}
    }
    
    // 重写动画样式
    override func dismiss() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.containerView.transform = .init(translationX: 0, y: -100)
            self.containerView.layer.borderWidth = 0
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
}
