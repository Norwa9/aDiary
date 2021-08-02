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
        dateLable.text = "\(weekDay)/\(month)/\(day)"
        
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
        
        self.addSubview(dateLable)
        self.addSubview(tagsView)
        self.addSubview(emojiView)
        self.addSubview(dismissBtn)
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
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
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
}


