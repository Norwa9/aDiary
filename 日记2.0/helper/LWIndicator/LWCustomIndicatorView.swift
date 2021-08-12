//
//  LWCustomIndicatorView.swift
//  日记2.0
//
//  Created by yy on 2021/8/12.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class LWCustomIndicatorView:UIView{
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
        
        ///其它情况
        ///删除、搜索过滤
        case other
    }
    
    var topWindow:UIWindow {
        get{
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        }
    }
    
    ///菊花指示器图层
    var indicatorView:NVActivityIndicatorView!
    ///进度条
    var progressView:UIProgressView!
    
    var label:UILabel!
    
    ///高斯模糊图层
    var blurEffectView:UIVisualEffectView!
    
    ///指示器的容器图层
    var containerView:UIView!
    
    init(withType type:indicatorType) {
        super.init(frame: .zero)
        initUI()
        setBaseConstrains()
        updateConstrains(withType: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-public
    
    
    //MARK:-private
    private func initUI() {
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        progressView.alpha = 0
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .systemGray2, padding: .zero)
        
        //提示lable
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "DIN Alternate", size: 22)
        label.textColor = .label
        
        //模糊视图
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //指示器+模糊视图的容器视图
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        //背景视图
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(indicatorView)
        containerView.addSubview(progressView)
        containerView.addSubview(label)
        self.addSubview(containerView)
        
    }
    
    //MARK:-设置约束
    private func setBaseConstrains(){
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(5)
            make.width.equalToSuperview().offset(-10)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(indicatorView.snp.bottom)
            make.height.lessThanOrEqualTo(60)
            make.bottom.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        
    }
    
    //MARK:-根据type配置不同的indicator view的约束
    private func updateConstrains(withType type:indicatorType){
        self.containerView.snp.removeConstraints()
        switch type{
        ///正中央
        case .fetchRemoteChange,.checkRemoteChange,.iap,.other:
            progressView.alpha = 0
            indicatorView.alpha = 1
        ///进度条
        case .progress:
            progressView.progress = 0
            progressView.alpha = 1
            indicatorView.alpha = 0
            self.containerView.snp.updateConstraints { update in
                update.size.equalTo(CGSize(width: 200, height: 20))
            }
        }
    }
}
