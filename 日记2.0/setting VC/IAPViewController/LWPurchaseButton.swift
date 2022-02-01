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
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startSpin(){
        self.spinner.startAnimating()
        
    }
    
    public func stopSpin(price:String){
        UIView.animate(withDuration: 0.5) {
            self.priceLabel.alpha = 1
            self.priceLabel.text = price
            self.spinner.stopAnimating()
        }
        
    }
    
    private func initUI(){
        self.setupShadow()
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
        self.clipsToBounds = false
        
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        
        purchaseTitle = UILabel()
        purchaseTitle.font = UIFont.boldSystemFont(ofSize: 20)
        purchaseTitle.text = "解锁永久版"
        
        priceLabel = UILabel()
        priceLabel.font = UIFont.boldSystemFont(ofSize: 30)
        priceLabel.alpha = 0
        
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
