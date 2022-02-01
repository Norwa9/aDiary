//
//  LWAppFeatureLabel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/31.
//

import UIKit

class LWAppFeatureLabel: UICollectionViewCell {
    static let cellHeight:CGFloat = 30 // labelH(20) + 2 * padding(5)
    let RegularFont:UIFont = .systemFont(ofSize: 16)
    
    var number:String!
    var feature:String!
    private var containerView:UIView!
    private var numberLabel:UILabel!
    private var numberHolderView:UIView!
    private var featureLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func setModel(_ model:(String,String)){
        self.number = (model.0)
        self.feature = model.1
        initUI()
        initCons()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        containerView = UIView()
        
        
        numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.font = .boldSystemFont(ofSize: 16) // 
        numberLabel.textAlignment = .center
        
        numberHolderView = UIView()
        numberHolderView.backgroundColor = UIColor.colorWithHex(hexColor: 0xC4C4C4)
        numberHolderView.layer.cornerRadius = 2
        
        featureLabel = UILabel()
        featureLabel.text = feature
        featureLabel.font = IAPViewController.iapVCContentFont
        
        
        self.addSubview(containerView)
        containerView.addSubview(numberHolderView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(featureLabel)
    }
    
    private func initCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(numberHolderView)
            make.centerY.equalToSuperview()
        }
        
        numberHolderView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 15, height: 6))
            make.centerX.equalTo(numberLabel)
            make.bottom.equalTo(numberLabel)
        }
        
        featureLabel.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(20)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            // 30 = 20 + 5 + 5
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
}
