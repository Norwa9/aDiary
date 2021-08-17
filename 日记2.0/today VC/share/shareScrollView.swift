//
//  shareScrollView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit
import TagListView
///分享视图
class shareScrollView:UIScrollView{
    let kContentW = globalConstantsManager.shared.kBoundsFrameOfShareView.width
    ///分享日期
    let dateLabel = UILabel()
    ///emoji
    let emojisLabel = UILabel()
    ///标签
    let tagsLabel = TagListView()
    ///日记内容的快照
    let textImageView = UIImageView()
    ///用户签名
    let signature = UILabel()
    ///图标
    let iconView = IconView()
    
    var scrollViewScreenshot:UIImage!
    var textViewScreenshot:UIImage
    var diary:diaryInfo
    
    init(frame: CGRect,snapshot:UIImage,diary:diaryInfo) {
        self.textViewScreenshot = snapshot
        self.diary = diary
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.backgroundColor = .systemBackground
        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = false
        
        dateLabel.textAlignment = .center
        dateLabel.text = diary.date + " " + GetWeekday(dateString: diary.date)
        dateLabel.font = userDefaultManager.customFont(withSize: 24)
        dateLabel.textColor = .label
        
        emojisLabel.attributedText = diary.emojis.joined().changeWorldSpace(space: -7)
        
        for tag in diary.tags{
            tagsLabel.addTag("#\(tag)")
        }
        tagsLabel.textFont = userDefaultManager.customFont(withSize: 14)
        tagsLabel.alignment = .left
        tagsLabel.tagBackgroundColor = .systemGray3
        tagsLabel.textColor = .white
        tagsLabel.cornerRadius = 5
        tagsLabel.clipsToBounds = true
        tagsLabel.isUserInteractionEnabled = false
        
        textImageView.contentMode = .scaleAspectFill///!!!!!!!
        textImageView.image = textViewScreenshot
        textImageView.layer.cornerRadius = 10
        textImageView.layer.borderWidth = 1
        textImageView.layer.borderColor = UIColor.systemGray2.cgColor
        
        signature.text = "via 'aDiary'  "
        signature.textColor = UIColor.secondaryLabel
        signature.font = UIFont.init(name: "DIN Alternate", size: 15)!
        signature.textAlignment = .right
        
        iconView.iconImageView.image = UIImage(named: "icon-1024")
        
        self.addSubview(dateLabel)
        self.addSubview(emojisLabel)
        self.addSubview(tagsLabel)
        self.addSubview(textImageView)
        self.addSubview(signature)
        self.addSubview(iconView)
        
    }
    
    func setupConstraints(){
        /*
         1.宽度必须设置为kContentW，不能为self.bounds.width，否者有偏差。为啥？
         2.make.centerX.equalTo(self)，子视图不能设置这条约束，否者截图的偏移中心的
         综上：
            最简单的办法还是使用frame来布局scrollview
            如果要用autolayout，在新建一个containerView，在上面布局子视图：https://www.programmersought.com/article/49414569566/
         */
        self.dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            //make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(kContentW)
        }
        
        self.emojisLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(4)
            make.width.equalTo(kContentW)
        }
        
        self.tagsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emojisLabel.snp.bottom).offset(5)
            make.centerX.equalTo(dateLabel)
            make.width.equalTo(kContentW - 20)//左右缩进各5
        }
        
        let textViewWidth = kContentW - 10
        let textViewHeight = textViewScreenshot.size.height / textViewScreenshot.size.width * textViewWidth
        self.textImageView.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self.snp.centerX) ❌
            make.top.equalTo(tagsLabel.snp.bottom).offset(4)
            make.centerX.equalTo(dateLabel)
            make.width.equalTo(textViewWidth)
            make.height.equalTo(textViewHeight)
        }
        
        self.signature.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self.snp.centerX) ❌
            make.top.equalTo(self.textImageView.snp.bottom).offset(5)
            make.width.equalTo(kContentW - 20)
            make.height.equalTo(25)
            make.bottom.equalTo(self).offset(-10)
        }
        
        self.layoutIfNeeded()//获取正确的frame
        contentSize = CGSize(width: kContentW, height: dateLabel.frame.height + emojisLabel.frame.height + tagsLabel.frame.height + textImageView.frame.height + signature.frame.height + 20)
        self.scrollViewScreenshot = getScreenshot(contentSize: contentSize)
        
    }
    
    ///截图
    func getScreenshot(contentSize:CGSize) -> UIImage{
        let savedContentOffset = contentOffset
        let savedFrame = frame
        defer {
            contentOffset = savedContentOffset
            frame = savedFrame
        }
        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        let image = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: contentSize)).image { renderer in
            let context = renderer.cgContext
            layer.render(in: context)
        }
        return image
    }
    
}




//MARK:-class:iconView图标视图类
class IconView: UIView {
    let iconImageView = UIImageView()
    let appNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 2
        self.setupShadow(opacity: 0.5, radius: 1, offset: CGSize(width: 0, height: 0), color: .black)
        
        self.addSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 2
        
        
        self.addSubview(appNameLabel)
        appNameLabel.font = UIFont.systemFont(ofSize: 11)
        appNameLabel.textAlignment = .center
        appNameLabel.text = "aDiary"
        appNameLabel.textColor = .white
        appNameLabel.alpha = 0
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.appNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(15)
        }
    }
    
    
    
}
