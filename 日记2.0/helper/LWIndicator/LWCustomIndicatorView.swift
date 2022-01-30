//
//  LWCustomIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit

///指示器的样式
enum indicatorType:Int{
    ///打开App时获取云端变化
    case checkRemoteChange
    
    ///App运行过程中接收到云端变化
    case fetchRemoteChange
    
    ///导出
    case progress
    
    ///内购
    case iap
    
    ///恢复
    case recover
    
    ///删除
    case delete
    
    ///其它情况
    ///搜索过滤
    case other
}

class LWCustomIndicatorView:UIView{
    var topWindow:UIWindow {
        get{
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        }
    }
    
    ///加载时的提示语句
    var label:UILabel!
    
    ///高斯模糊图层
    var blurEffectView:UIVisualEffectView!
    
    ///指示器的容器图层
    var containerView:UIView!
    
    init() {
        super.init(frame: .zero)
        initUI()
        setBaseConstrains()   
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -public
    
    public func setLabel(_ text:String){
        label.text = text
        layoutIfNeeded()
    }
    
    //MARK: -protected
    func present(){
        
    }
    
    func dismiss(){
        
    }
    ///初始化UI
    func initUI() {
        //提示lable
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "DIN Alternate", size: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        
        //模糊视图
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //指示器+模糊视图的容器视图
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(label)
        self.addSubview(containerView)
    }
    
    ///设置约束
    func setBaseConstrains(){
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        
        label.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(60)
            make.bottom.equalToSuperview().offset(-5)
            make.left.greaterThanOrEqualTo(containerView).offset(10)
            make.right.lessThanOrEqualTo(containerView).offset(-10)
            make.centerX.equalToSuperview()
        }
        
    }
}
