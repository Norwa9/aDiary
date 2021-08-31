//
//  TopView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/30.
//

import UIKit
import TagListView

let kEmojiViewHeight:CGFloat = 25
class TopView: UIView {
    ///模型
    var model:diaryInfo!{
        didSet{
            setModel()
        }
    }
    
    ///日期
    var dateLable:UILabel!
    
    ///标签托盘
    var tagsView:LWTagsView!
    
    ///心情托盘
    var emojiView:LWEmojiView!
    
    var dismissBtn:UIButton!
    
    var multiPagesBtn:UIButton!
    
    var fullScreenBtn:UIButton!
    
    init() {
        super.init(frame: .zero)
        initUI()
        setConstriants()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(){
        updateUI()
    }
    
    private func updateUI(){
        //从model获取日期
        let day = model.date.dateComponent(for: .day)
        let month = model.date.dateComponent(for: .month)
        let weekDay = model.date.dateComponent(for: .weekday)
        dateLable.text = "\(month)月\(day)日 \(weekDay)"
        dateLable.font = userDefaultManager.customFont(withSize: 22).bold()
        //更新约束
        updateCons()
        
        //给emojiView和tagsView装填视图
        emojiView.model = model
        tagsView.model = model
    }
    
    private func initUI(){
        //日期
        dateLable = UILabel()
        dateLable.font = userDefaultManager.customFont(withSize: 22)
        
        //心情
        emojiView = LWEmojiView()
        
        //标签
        tagsView = LWTagsView()
        
        //关闭按钮
        dismissBtn = UIButton()
        dismissBtn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        multiPagesBtn = UIButton()
        multiPagesBtn.setImage(#imageLiteral(resourceName: "multipages"), for: .normal)
        multiPagesBtn.addTarget(self, action: #selector(manageMultiPages(_:)), for: .touchUpInside)
        
        fullScreenBtn = UIButton()
        fullScreenBtn.setImage(#imageLiteral(resourceName: "fullscreenOn"), for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(toggleFullScreen(_:)), for: .touchUpInside)
        
        self.addSubview(dateLable)
        self.addSubview(tagsView)
        self.addSubview(emojiView)
        self.addSubview(dismissBtn)
        self.addSubview(multiPagesBtn)
        self.addSubview(fullScreenBtn)
    }
    
    private func setConstriants(){
        dateLable.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        emojiView.snp.makeConstraints { (make) in
            make.top.equalTo(dateLable.snp.bottom).offset(2)
            make.centerX.equalTo(dateLable)
            make.width.equalTo(0)
            make.height.equalTo(25)
        }
        
        tagsView.snp.makeConstraints { (make) in
            make.leading.right.equalToSuperview()
            make.top.equalTo(emojiView.snp.bottom).offset(2)
            make.height.greaterThanOrEqualTo(0)
            make.height.lessThanOrEqualTo(100)
            make.bottom.equalToSuperview()
        }
        
        dismissBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(dateLable)
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        multiPagesBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 35, height: 35))
            make.right.equalTo(dismissBtn.snp.left).offset(-10)
            make.centerY.equalTo(dismissBtn)
        }
        
        fullScreenBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 35, height: 35))
            make.right.equalTo(multiPagesBtn.snp.left).offset(-10)
            make.centerY.equalTo(dismissBtn)
        }
        
    }
    
    private func updateCons(){
        self.layoutIfNeeded()
    }
    
    //MARK:-target action
    @objc func dismiss(){
        UIApplication.getTodayVC()?.dismiss(animated: true, completion: nil)
    }
    
    @objc func manageMultiPages(_ sender:UIButton){
        multiPagesBtn.bounceAnimation(usingSpringWithDamping: 0.7)
        UIApplication.getTodayVC()?.subpagesView.manageMutiPages(sender)
    }
    
    @objc func toggleFullScreen(_ sender:UIButton){
        guard let todayVC = UIApplication.getTodayVC() else{return}
        
        todayVC.toggleTopView()
        
        //更新图片
        let imageName = todayVC.isShowingTopView ? "fullscreenOff" : "fullscreenOn"
        let image = UIImage(named: imageName)!
        fullScreenBtn.bounceAnimation(usingSpringWithDamping: 0.7)
        fullScreenBtn.setImage(image, for: .normal)
    }
    
    func updateTopView(isShowing:Bool){
        self.emojiView.snp.updateConstraints { (update) in
            update.height.equalTo(isShowing ? 25 : 0)
        }
        self.tagsView.snp.updateConstraints { (update) in
            update.height.lessThanOrEqualTo(isShowing ? 100 : 0)
        }
        
    }
}


