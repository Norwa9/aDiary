//
//  TopView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/30.
//

import UIKit
import TagListView

let kEmojiViewHeight = ktopViewHeight

class TopView: UIView {
    ///模型
    var model:diaryInfo
    
    ///日期
    var dateLable:UILabel!
    
    ///标签托盘
    var tagsView:LWTagsView!
    
    ///心情托盘
    var emojiView:LWEmojiView!
    
    init(model:diaryInfo) {
        self.model = model
        
        super.init(frame: .zero)
        initUI()
        setConstriants()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        //日期
        dateLable = UILabel()
        let day = model.date.dateComponent(for: .day)
        let month = model.date.dateComponent(for: .month)
        let weekDay = model.date.dateComponent(for: .weekday)
        dateLable.font = UIFont(name: "DIN Alternate", size: 24)
        dateLable.text = "\(month)月\(day)日,\(weekDay)"
        
        //心情
        emojiView = LWEmojiView(model: self.model)
        
        //标签
        tagsView = LWTagsView(model: self.model)
        
        self.addSubview(dateLable)
        self.addSubview(tagsView)
        self.addSubview(emojiView)
    }
    
    private func setConstriants(){
        dateLable.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
        }
        
        emojiView.snp.makeConstraints { (make) in
            make.leading.equalTo(dateLable.snp.trailing).offset(2)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(emojiView.snp.height)
        }
        
        tagsView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.bottom.equalTo(emojiView)
            make.leading.equalTo(emojiView.snp.trailing).offset(2)
        }
        
        
    }
}


