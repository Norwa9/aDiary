//
//  IAPViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import UIKit

class IAPViewController: UIViewController {
    var IAPHelper:LWIAPHelper!
    
    var button1:UIButton!
    var label1:UILabel!
    var productView1:ProductDisplayView!
    var restoreBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        initUI()
        setupCons()
        
        //IAPHelper
        initIAPHelper()
    }
    private func initIAPHelper(){
        IAPHelper = LWIAPHelper.shared
        
        IAPHelper.fetchProductsCompletionBlock = { (products) in
            if products.count >= 2{
                self.productView1.setModel(products[1])
            }
        }
        
        IAPHelper.restoreCompletionBlock = {
            
        }
        
        
        IAPHelper.requestProducts()//开始工作
    }
    
    private func initUI(){
        productView1 = ProductDisplayView()
        productView1.setDebugBorder()
        self.view.addSubview(productView1)
        
        label1 = UILabel()
        label1.setDebugBorder()
        self.view.addSubview(label1)
        
        button1 = UIButton()
        button1.setDebugBorder()
        button1.setTitle("订阅", for: .normal)
        self.view.addSubview(button1)
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        
        restoreBtn = UIButton()
        restoreBtn.setDebugBorder()
        restoreBtn.setTitle("恢复", for: .normal)
        self.view.addSubview(restoreBtn)
        restoreBtn.addTarget(self, action: #selector(restoreBtnAction), for: .touchUpInside)
    }
    
    private func setupCons(){
        productView1.snp.makeConstraints { (make) in
            make.bottom.equalTo(label1.snp.top)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 200))
        }
        
        label1.snp.makeConstraints { (make) in
            make.bottom.equalTo(button1.snp.top)
            make.centerX.equalTo(button1)
            make.size.equalTo((CGSize(width: 400, height: 50)))
        }
        
        button1.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.center.equalToSuperview()
        }
        
        restoreBtn.snp.makeConstraints { (make) in
            make.top.equalTo(button1.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
}

//MARK:-actions
extension IAPViewController{
    ///
    @objc func button1Action(){
        if let product = productView1.product{
            indicatorViewManager.shared.start()
            IAPHelper.buy(product: product)
        }
    }
    
    ///恢复所有订阅
    @objc func restoreBtnAction(){
        indicatorViewManager.shared.start()
        IAPHelper.restore()
    }
}


