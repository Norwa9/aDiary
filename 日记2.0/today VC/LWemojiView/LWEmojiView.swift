//
//  LWEmojiView.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit

class LWEmojiView: UIView {
    var stack:[String] = []
    var textField:UITextField!
    
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
        self.backgroundColor = APP_GRAY_COLOR()
        
        textField = UITextField()
        textField.placeholder = "😁"
        
        
        self.addSubview(textField)
    }
    
    func setupCons(){
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func add(emoji:String){
        
    }
    
    
}
