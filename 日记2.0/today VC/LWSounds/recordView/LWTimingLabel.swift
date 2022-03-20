//
//  LWTimingLabel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit

class LWTimingLabel:UIView{
    var time:CGFloat!{
        didSet{
            self.timingLabel.text = getConvertedTime(count: time)
        }
    }
    private var timingLabel:UILabel!
    
    
    init() {
        super.init(frame: .zero)
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 10
        self.backgroundColor = .secondarySystemBackground
        
        timingLabel = UILabel()
        timingLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        timingLabel.textAlignment = .center
        time = 0
        
        
        self.addSubview(timingLabel)
    }
    
    func setupCons(){
        timingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    
    
    
    
}
