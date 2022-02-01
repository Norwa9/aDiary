//
//  IAPViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/7.
//

import UIKit

class IAPViewController: UIViewController {
    var IAPHelper:LWIAPHelper!
    
    private var iconImageView:UIImageView!
    private var closBtn:UIButton!
    
    private var freeEditionTitleLabel:UILabel!
    private var freeEditionContentLabel:UILabel!
    let freeEditionFeaturesModels:[(String,String)] = [
        ("1","iCloud云同步"),
        ("2","PDF导出备份"),
        ("3","无限插图"),
        ("4","无限标签"),
        ("···","")
    ]
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
        ("2","计划Pro功能:日记模板，个性化标签等"),
    ]
    private var proEditionFeaturesCollectionView:UICollectionView!
    private var proEditionFeaturesCollectionViewHeight:CGFloat{
        get{
            return CGFloat(proEditionFeaturesModels.count) * LWAppFeatureLabel.cellHeight
        }
    }
    
    private var purchaseBtn:LWPurchaseButton!
    private var freeTrialStateLabel:UILabel!
    
    private var restoreBtn:UIButton!
    
    static let iapVCTitleFont = UIFont.boldSystemFont(ofSize: 30)
    static let iapVCContentFont = UIFont.systemFont(ofSize: 16)
    
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
        
        self.purchaseBtn.startSpin()
        IAPHelper.fetchProductsCompletionBlock = { (products) in
            self.purchaseBtn.stopSpin(price: "6元")
            if products.count >= 2{
                
            }
        }
        
        IAPHelper.restoreCompletionBlock = {
            
        }
        
        
        IAPHelper.requestProducts()//开始工作
    }
    
    private func initUI(){
        iconImageView = UIImageView(image: UIImage(named: "icon_roundCornor"))
        
        closBtn = UIButton()
        closBtn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        closBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        
        freeEditionTitleLabel = UILabel()
        freeEditionTitleLabel.font = IAPViewController.iapVCTitleFont
        freeEditionTitleLabel.text = "免费版"
        freeEditionContentLabel = UILabel()
        freeEditionContentLabel.textColor = UIColor.secondaryLabel
        freeEditionContentLabel.font = IAPViewController.iapVCContentFont
        freeEditionContentLabel.text = "提供包括但将不限于以下的免费功能："
        let layout1 = UICollectionViewFlowLayout()
        layout1.itemSize = CGSize(width: globalConstantsManager.shared.kScreenWidth - 30 * 2, height: LWAppFeatureLabel.cellHeight) // 30是collectionView左边的offset
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
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: globalConstantsManager.shared.kScreenWidth - 30 * 2, height: LWAppFeatureLabel.cellHeight)
        layout2.minimumLineSpacing = 0
        layout2.sectionInset = .zero
        proEditionFeaturesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        proEditionFeaturesCollectionView.accessibilityIdentifier = "pro"
        proEditionFeaturesCollectionView.delegate = self
        proEditionFeaturesCollectionView.dataSource = self
        proEditionFeaturesCollectionView.register(LWAppFeatureLabel.self, forCellWithReuseIdentifier: "iapCell")
        
        purchaseBtn = LWPurchaseButton(selector: #selector(purchaseAction), delegate: self)
        
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
        
        view.addSubview(iconImageView)
        view.addSubview(closBtn)
        
        view.addSubview(freeEditionTitleLabel)
        view.addSubview(freeEditionContentLabel)
        view.addSubview(freeEditionFeaturesCollectionView)
        
        view.addSubview(proEditionTitleLabel)
        view.addSubview(proEditionContentLabel)
        view.addSubview(proEditionFeaturesCollectionView)
        
        view.addSubview(purchaseBtn)
        view.addSubview(freeTrialStateLabel)
        view.addSubview(restoreBtn)
    }
    
    private func setupCons(){
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
        
        // 恢复
        restoreBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
        
        // 试用
        freeTrialStateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(restoreBtn.snp.top).offset(-30)
        }
        
        // 购买
        purchaseBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200, height: 60))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(freeTrialStateLabel.snp.top).offset(-6)
        }
        
    }
}

//MARK:-actions
extension IAPViewController{
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    ///
    @objc func purchaseAction(){
//        if let product = productView1.product{
//            indicatorViewManager.shared.start(type: .iap)
//            IAPHelper.buy(product: product)
//        }
    }
    
    ///恢复所有订阅
    @objc func restoreBtnAction(){
        indicatorViewManager.shared.start(type: .iap)
        IAPHelper.restore()
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
