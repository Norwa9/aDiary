//
//  IAPViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import UIKit
import StoreKit

class IAPViewController: UIViewController {
    static let iapVCTitleFont = UIFont.boldSystemFont(ofSize: 30)
    static let iapVCContentFont = UIFont.systemFont(ofSize: 16)
    private var collectionViewWidth:CGFloat{
        get{
            return self.view.width
        }
    }
    
    var IAPHelper:LWIAPHelper!
    
    private var scrollView:UIScrollView!
    private var containerView:UIView!
    
    private var iconImageView:UIImageView!
    private var closBtn:UIButton!
    
    private var freeEditionTitleLabel:UILabel!
    private var freeEditionContentLabel:UILabel!
    let freeEditionFeaturesModels:[(String,String)] = [
        ("1","iCloud双端同步"),
        ("2","PDF导出备份"),
        ("3","无限插图"),
        ("4","无限标签"),
        ("···","")
    ]
    private var layout1:UICollectionViewFlowLayout!
    private var freeEditionFeaturesCollectionView:UICollectionView!
    private var FreeEditionFeaturesCollectionViewHeight:CGFloat{
        get{
            return CGFloat(freeEditionFeaturesModels.count) * LWAppFeatureLabel.cellHeight
        }
    }
        
    
    
    private var proEditionTitleLabel:UILabel!
    private var proEditionContentLabel:UILabel!
    let proEditionFeaturesModels:[(String,String)] = [
        ("1","为todo设置提醒时间与备注"),
        ("2","创建无限量的日记模板"),
        ("3","未来持续更新的Pro功能"),
    ]
    private var layout2:UICollectionViewFlowLayout!
    private var proEditionFeaturesCollectionView:UICollectionView!
    private var proEditionFeaturesCollectionViewHeight:CGFloat{
        get{
            return CGFloat(proEditionFeaturesModels.count) * LWAppFeatureLabel.cellHeight
        }
    }
    
    private var purchaseBtn:LWPurchaseButton!
    private var freeTrialStateLabel:UILabel!
    private var restoreBtn:UIButton!
    
    var products:[SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        initUI()
        setupCons()
        
        //IAPHelper
        initIAPHelper()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout1.itemSize = CGSize(width: collectionViewWidth - 30 * 2, height: LWAppFeatureLabel.cellHeight) // 30是collectionView左边的offset
        layout2.itemSize = CGSize(width: collectionViewWidth - 30 * 2, height: LWAppFeatureLabel.cellHeight) // 30是collectionView左边的offset
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let settingVC = self.presentingViewController as? LWSettingViewController{
            // 退出时更新 iap cell的升级按钮的文案
            settingVC.iapSettingCell.updatePurchasedButton()
        }
    }
    
    private func initIAPHelper(){
        IAPHelper = LWIAPHelper.shared
        
        // 购买完成的回调
        IAPHelper.purchaseCompletionBlock = {
            userDefaultManager.purchaseEdition = .purchased
            self.purchaseBtn.updateButtonState()
            self.freeTrialStateLabel.alpha = 0 // 购买完成后隐藏试用label
            DispatchQueue.main.async {
                indicatorViewManager.shared.stop()
            }
        }
        
        // 恢复购买的回调
        IAPHelper.restoreCompletionBlock = {
            userDefaultManager.purchaseEdition = .purchased
            self.purchaseBtn.updateButtonState()
            DispatchQueue.main.async {
                indicatorViewManager.shared.stop()
            }
        }
        
        // 取回内购项目的回调
        IAPHelper.fetchProductsCompletionBlock = { (products) in
            print("products.count:\(products.count)")
            // 已调取到可购买项目
            // （3.2版本引入内购后，暂时仅有永久版，所以返回的products应该是一个元素）
            if let product = products.first, // 永久版
               product.productIdentifier == LWProductIdentifier.permanent.rawValue,
               let price = product.regularPrice
            {
                self.products = products
                self.purchaseBtn.stopSpin(returnPrice: price)
            }
        }
        
        // 如果没有购买，则请求内购项目，刷新购买按钮内容
        if userDefaultManager.purchaseEdition != .purchased{
            IAPHelper.requestProducts() // 请求调取可内购项目
            self.purchaseBtn.startSpin()
        }
    }
    
    private func initUI(){
        iconImageView = UIImageView(image: UIImage(named: "icon_roundCornor"))
        
        closBtn = UIButton()
        closBtn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        closBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        scrollView = UIScrollView()
        containerView = UIView()
        
        freeEditionTitleLabel = UILabel()
        freeEditionTitleLabel.font = IAPViewController.iapVCTitleFont
        freeEditionTitleLabel.text = "免费版"
        freeEditionContentLabel = UILabel()
        freeEditionContentLabel.textColor = UIColor.secondaryLabel
        freeEditionContentLabel.font = IAPViewController.iapVCContentFont
        freeEditionContentLabel.text = "提供包括但将不限于以下的免费功能："
        layout1 = UICollectionViewFlowLayout()
        layout1.minimumLineSpacing = 0
        layout1.sectionInset = .zero
        freeEditionFeaturesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout1)
        freeEditionFeaturesCollectionView.accessibilityIdentifier = "free"
        freeEditionFeaturesCollectionView.delegate = self
        freeEditionFeaturesCollectionView.dataSource = self
        freeEditionFeaturesCollectionView.register(LWAppFeatureLabel.self, forCellWithReuseIdentifier: "iapCell")
        
        proEditionTitleLabel = UILabel()
        proEditionTitleLabel.font = IAPViewController.iapVCTitleFont
        proEditionTitleLabel.text = "升级到Pro"
        proEditionContentLabel = UILabel()
        proEditionContentLabel.textColor = UIColor.secondaryLabel
        proEditionContentLabel.font = IAPViewController.iapVCContentFont
        proEditionContentLabel.text = "支持开发者未来的工作，以及获取更完整体验："
        layout2 = UICollectionViewFlowLayout()
        layout2.minimumLineSpacing = 0
        layout2.sectionInset = .zero
        proEditionFeaturesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        proEditionFeaturesCollectionView.accessibilityIdentifier = "pro"
        proEditionFeaturesCollectionView.delegate = self
        proEditionFeaturesCollectionView.dataSource = self
        proEditionFeaturesCollectionView.register(LWAppFeatureLabel.self, forCellWithReuseIdentifier: "iapCell")
        
        purchaseBtn = LWPurchaseButton(selector: #selector(purchasePermanentEdition), delegate: self)
        
        freeTrialStateLabel = UILabel()
        freeTrialStateLabel.font = .systemFont(ofSize: 14)
        freeTrialStateLabel.textColor = UIColor.secondaryLabel
        if userDefaultManager.purchaseEdition == .freeTrial{
            if let endDate = userDefaultManager.downloadDate?.plusOneDay(){
                freeTrialStateLabel.text = "状态：试用中（至\(endDate)）"
            }
        }else{
            freeTrialStateLabel.alpha = 0
        }
        
        
        restoreBtn = UIButton()
        let resoreTile = NSAttributedString(string: "恢复购买").addingAttributes([
            .foregroundColor : UIColor.link,
            .underlineStyle : 1,
            .font : UIFont.systemFont(ofSize: 14)
        ])
        restoreBtn.setAttributedTitle(resoreTile, for: .normal)
        restoreBtn.addTarget(self, action: #selector(restoreBtnAction), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(closBtn)
        
        containerView.addSubview(freeEditionTitleLabel)
        containerView.addSubview(freeEditionContentLabel)
        containerView.addSubview(freeEditionFeaturesCollectionView)
        
        containerView.addSubview(proEditionTitleLabel)
        containerView.addSubview(proEditionContentLabel)
        containerView.addSubview(proEditionFeaturesCollectionView)
        
        containerView.addSubview(purchaseBtn)
        containerView.addSubview(freeTrialStateLabel)
        containerView.addSubview(restoreBtn)
    }
    
    private func setupCons(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        
        // free
        iconImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(30)
            make.size.equalTo(CGSize(width: 67, height: 67))
        }
        
        closBtn.snp.makeConstraints { make in
            make.top.equalTo(iconImageView)
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        freeEditionTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(iconImageView.snp.bottom).offset(25)
        }
        
        freeEditionContentLabel.snp.makeConstraints { make in
            make.left.equalTo(freeEditionTitleLabel)
            make.top.equalTo(freeEditionTitleLabel.snp.bottom).offset(15)
        }
        
        freeEditionFeaturesCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.top.equalTo(freeEditionContentLabel.snp.bottom).offset(15)
            make.height.equalTo(FreeEditionFeaturesCollectionViewHeight) // 必须手动设置高度，否者不会调用cellForItemAt
        }
        
        // pro
        proEditionTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(freeEditionTitleLabel)
            make.top.equalTo(freeEditionFeaturesCollectionView.snp.bottom).offset(15)
        }
        
        proEditionContentLabel.snp.makeConstraints { make in
            make.left.equalTo(proEditionTitleLabel)
            make.top.equalTo(proEditionTitleLabel.snp.bottom).offset(15)
        }
        
        proEditionFeaturesCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.top.equalTo(proEditionContentLabel.snp.bottom).offset(15)
            make.height.equalTo(proEditionFeaturesCollectionViewHeight)
        }
        
        // 购买
        purchaseBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200, height: 60))
            make.centerX.equalToSuperview()
            make.top.equalTo(proEditionFeaturesCollectionView.snp.bottom).offset(50)
        }
        
        // 试用
        freeTrialStateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(purchaseBtn.snp.bottom).offset(6)
        }
        
        // 恢复
        restoreBtn.snp.makeConstraints { (make) in
            make.top.equalTo(freeTrialStateLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
        
    }
}

//MARK:  -actions
extension IAPViewController{
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 购买永久版
    @objc func purchasePermanentEdition(){
        if let product = products.first{
            indicatorViewManager.shared.start(type: .iap)
            IAPHelper.buy(product: product)
        }else{
            
        }
    }
    
    ///恢复所有订阅
    @objc func restoreBtnAction(){
        if userDefaultManager.purchaseEdition == .purchased{
            LWIAPHelper.shared.generatePurchasedAC()
        }else{
            indicatorViewManager.shared.start(type: .iap)
            IAPHelper.restore()
        }
        
    }
}

extension IAPViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count:Int
        if let id = collectionView.accessibilityIdentifier{
            if id == "free"{
                count =  freeEditionFeaturesModels.count
            }else if id == "pro"{
                count =  proEditionFeaturesModels.count
            }else{
                count = 0
            }
        }else{
            count = 0
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iapCell", for: indexPath) as! LWAppFeatureLabel
        if let id = collectionView.accessibilityIdentifier{
            if id == "free"{
                cell.setModel(freeEditionFeaturesModels[indexPath.row])
            }else if id == "pro"{
                cell.setModel(proEditionFeaturesModels[indexPath.row])
            }else{
                //
            }
        }
        // cell.setDebugBorder()
        return cell
    }
    
    
}
