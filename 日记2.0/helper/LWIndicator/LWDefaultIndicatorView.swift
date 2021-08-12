//
//  LWDefaultIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit


class LWDefaultIndicatorView: LWCustomIndicatorView {
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
}
