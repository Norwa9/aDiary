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
        progressView.progress = 0
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

}
