//
//  LWDefaultIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class LWDefaultIndicatorView: LWCustomIndicatorView {
    ///菊花指示器图层
    var indicatorView:NVActivityIndicatorView!
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI() {
        super.initUI()
        
        containerView.layer.cornerRadius = 10
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .systemGray2, padding: .zero)
        containerView.addSubview(indicatorView)
    }
    
    override func setBaseConstrains() {
        super.setBaseConstrains()
        
        indicatorView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(containerView).offset(10)
            make.right.lessThanOrEqualTo(containerView).offset(-10)
            make.bottom.equalTo(label.snp.top)
        }
    }
    
    override func present() {
        indicatorView.startAnimating()
        containerView.alpha = 0
        indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
        backgroundColor = .clear
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.indicatorView.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        } completion: { (_) in}
    }
    
    override func dismiss() {
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
            self.backgroundColor = .clear
        } completion: { (_) in
            self.indicatorView.stopAnimating()
            self.containerView.alpha = 1
            self.indicatorView.transform = .identity
            self.removeFromSuperview()
        }
        
    }
}
