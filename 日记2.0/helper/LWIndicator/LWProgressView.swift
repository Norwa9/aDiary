//
//  LWProgressView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import UIKit

class LWProgressView: LWCustomIndicatorView {
    ///进度条
    var progressView:UIProgressView!
    
    override init() {
        super.init()
    }
    
    override func initUI() {
        super.initUI()
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        containerView.addSubview(progressView)
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
        
        progressView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 10))
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(containerView).offset(10)
            make.right.lessThanOrEqualTo(containerView).offset(-10)
            make.bottom.equalTo(label.snp.top)
        }
    }
    
    override func present() {
        self.containerView.alpha = 0
        self.progressView.transform = .init(scaleX: 0.01, y: 0.01)
        self.backgroundColor = .clear
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.progressView.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        } completion: { (_) in}
    }
    
    override func dismiss() {
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.progressView.transform = .init(scaleX: 0.01, y: 0.01)
            self.backgroundColor = .clear
        } completion: { (_) in
            self.containerView.alpha = 1
            self.progressView.transform = .identity
            self.removeFromSuperview()
        }
    }

}
