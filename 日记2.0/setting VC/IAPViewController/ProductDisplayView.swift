//
//  ProductDisplayView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import UIKit
import StoreKit
class ProductDisplayView: UIView {
    var product:SKProduct!
    var imageView:UIImageView = UIImageView()
    var label:UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        setupCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        
        self.addSubview(imageView)
        self.addSubview(label)
    }
    
    private func setupCons(){
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setModel(_ product:SKProduct){
        self.product = product
        self.label.text = product.localizedTitle
    }
}
