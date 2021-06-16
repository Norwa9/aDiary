//
//  shareScrollView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit
///分享视图
class shareScrollView:UIScrollView{
    let kContentW = blurPresentationController.frameOfPresentedView.size.width
    ///分享日期
    let dateLabel = UILabel()
    ///周几
    let weekLabel = UILabel()
    ///日记内容的快照
    let textImageView = UIImageView()
    ///用户签名
    let signature = UILabel()
    ///图标
    let icon = iconView()
    
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
        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = false
        
        dateLabel.textAlignment = .center
        dateLabel.text = diary.date
        dateLabel.font = UIFont.init(name: "DIN Alternate", size: 32)!
        
        weekLabel.textAlignment = .center
        weekLabel.text = Date().getWeekday(dateString: diary.date!)
        weekLabel.font = UIFont.init(name: "DIN Alternate", size: 24)!
        
        textImageView.contentMode = .scaleAspectFill///!!!!!!!
        textImageView.image = textViewScreenshot
        textImageView.layer.cornerRadius = 10
        textImageView.layer.borderWidth = 1
        textImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        signature.backgroundColor = .white
        signature.text = "分享自"
        signature.textColor = UIColor.gray
        signature.font = UIFont.init(name: "DIN Alternate", size: 18)!
        signature.textAlignment = .center
        
        icon.iconImageView.image = UIImage(named: "icon-1024")
        
        self.addSubview(dateLabel)
        self.addSubview(weekLabel)
        self.addSubview(textImageView)
        self.addSubview(signature)
        self.addSubview(icon)
        
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
        
        self.weekLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.dateLabel.snp.bottom)
            make.bottom.equalTo(self.textImageView.snp.top)
            make.width.equalTo(kContentW)
        }
        
        let textViewWidth = kContentW - 10
        let textViewHeight = textViewScreenshot.size.height / textViewScreenshot.size.width * textViewWidth
        self.textImageView.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self.snp.centerX) ❌
            make.centerX.equalTo(weekLabel)
            make.width.equalTo(textViewWidth)
            make.height.equalTo(textViewHeight)
        }
        
        self.signature.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self.snp.centerX) ❌
            make.top.equalTo(self.textImageView.snp.bottom).offset(10)
            make.width.equalTo(kContentW)
        }
        
        self.icon.snp.makeConstraints { (make) in
            make.top.equalTo(self.signature.snp.bottom).offset(2)
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerX.equalTo(signature.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
        
        self.layoutIfNeeded()//获取正确的frame
        contentSize = CGSize(width: kContentW, height: dateLabel.frame.height + weekLabel.frame.height + textImageView.frame.height + signature.frame.height + icon.frame.height + 20)
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




///图标视图
class iconView: UIView {
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
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.setupShadow(opacity: 0.5, radius: 1, offset: CGSize(width: 0, height: 0), color: .black)
        
        self.addSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        
        
        self.addSubview(appNameLabel)
        appNameLabel.font = UIFont.systemFont(ofSize: 11)
        appNameLabel.textAlignment = .center
        appNameLabel.text = "aDiary"
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        self.appNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(15)
        }
    }
    
    
    
}
