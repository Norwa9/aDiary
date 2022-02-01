//
//  LWPurchaseButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/1.
//

import UIKit
import NVActivityIndicatorView

class LWPurchaseButton: UIView {
    var purchaseSelector:Selector
    var delegate:IAPViewController
    private var containerView:UIView!
    private var spinner:NVActivityIndicatorView!
    private var purchaseTitle:UILabel!
    private var priceLabel:UILabel!
    
    init(selector:Selector,delegate:IAPViewController){
        self.purchaseSelector = selector
        self.delegate = delegate
        super.init(frame: .zero)
        
        let tapGes = UITapGestureRecognizer(target: delegate, action: selector)
        self.addGestureRecognizer(tapGes)
        
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startSpin(){
        self.priceLabel.alpha = 0
        self.isUserInteractionEnabled = false
        self.spinner.startAnimating()
        
    }
    
    public func stopSpin(returnPrice:String){
        UIView.animate(withDuration: 0.5) {
            self.priceLabel.alpha = 1
            self.priceLabel.text = returnPrice
            self.spinner.stopAnimating()
            self.isUserInteractionEnabled = true
        }
        
    }
    
    public func updateButtonState(){
        if userDefaultManager.purchaseEdition == .purchased{
            purchaseTitle.text = "已解锁永久版"
            priceLabel.text = "✅"
            self.isUserInteractionEnabled = false
        }else{
            purchaseTitle.text = "解锁永久版"
            self.isUserInteractionEnabled = true
        }
    }
    
    private func initUI(){
        self.setupShadow()
        self.backgroundColor = settingContainerDynamicColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = false
        
        containerView = UIView()
        containerView.backgroundColor = settingContainerDynamicColor
        containerView.layer.cornerRadius = 10
        
        purchaseTitle = UILabel()
        purchaseTitle.font = UIFont.boldSystemFont(ofSize: 20)
        purchaseTitle.adjustsFontSizeToFitWidth = true
        
        priceLabel = UILabel()
        priceLabel.font = UIFont.boldSystemFont(ofSize: 30)
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.textAlignment = .center
        
        
        updateButtonState() // 根据是否解锁显示不同标题
        
        spinner = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .label, padding: nil)
        
        self.addSubview(containerView)
        containerView.addSubview(purchaseTitle)
        containerView.addSubview(priceLabel)
        containerView.addSubview(spinner)
    }
    
    private func initCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        purchaseTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 110, height: 30))
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.right.equalToSuperview().offset(-10)
        }
        
        spinner.snp.makeConstraints { make in
            make.centerX.equalTo(priceLabel)
            make.centerY.equalTo(priceLabel)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    

}
