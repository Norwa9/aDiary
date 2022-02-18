//
//  LWCustomIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit
import NVActivityIndicatorView

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
    ///菊花指示器图层
    var indicatorView:NVActivityIndicatorView!
    
    ///进度条
    var progressView:UIProgressView!
    
    ///加载时的提示语句
    var label:UILabel!
    
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
        self.isUserInteractionEnabled = false //可让操作穿透该图层
        
        //指示器+模糊视图的容器视图
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.setupShadow()
        // containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.masksToBounds = false
        
        
        //提示lable
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "DIN Alternate", size: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .label, padding: .zero)
        
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        
        containerView.addSubview(label)
        containerView.addSubview(indicatorView)
        containerView.addSubview(progressView)
        self.addSubview(containerView)
    }
    
    ///设置约束
    func setBaseConstrains(){
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualToSuperview().offset(10)
            make.height.equalTo(label.snp.height)
            make.width.equalTo(label.snp.height)
            make.centerY.equalTo(label)
        }
        
        progressView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.top.equalToSuperview().offset(0)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(containerView).offset(10)
            make.right.lessThanOrEqualTo(containerView).offset(-10)
            make.bottom.equalTo(label.snp.top).offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(indicatorView.snp.right).offset(2)
            make.right.lessThanOrEqualToSuperview().offset(-10)
            //make.centerX.equalToSuperview()
        }
        
    }
}
