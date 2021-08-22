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
        
        //更新约束
        updateCons()
        
        //给emojiView和tagsView装填视图
        emojiView.model = model
        tagsView.model = model
    }
    
    private func initUI(){
        //日期
        dateLable = UILabel()
        dateLable.font = UIFont(name: "DIN Alternate", size: 22)
        
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
        
        self.addSubview(dateLable)
        self.addSubview(tagsView)
        self.addSubview(emojiView)
        self.addSubview(dismissBtn)
        self.addSubview(multiPagesBtn)
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
            make.height.greaterThanOrEqualTo(25)
            make.bottom.equalToSuperview()
        }
        
        dismissBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 35, height: 35))
        }
        
        multiPagesBtn.snp.makeConstraints { (make) in
            make.size.equalTo(dismissBtn)
            make.right.equalTo(dismissBtn.snp.left).offset(-10)
            make.centerY.equalTo(dismissBtn)
        }
        
    }
    
    private func updateCons(){
//        let emojiViewWidth = max(ceil(CGFloat(model.emojis.count) / 2) * kEmojiItemWidth, kEmojiViewWidth)
//        emojiView.snp.updateConstraints { (update) in
//            update.width.equalTo(emojiViewWidth)
//        }
        
        self.layoutIfNeeded()
    }
    
    //MARK:-target action
    @objc func dismiss(){
        UIApplication.getTodayVC()?.dismiss(animated: true, completion: nil)
    }
    
    @objc func manageMultiPages(_ sender:UIButton){
        UIApplication.getTodayVC()?.subpagesView.manageMutiPages(sender)
    }
}


