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
    
    ///其它情况
    ///删除、搜索过滤
    case other
}

class LWCustomIndicatorView:UIView{
    
    
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
    
    init() {
        super.init(frame: .zero)
        initUI()
        setBaseConstrains()   
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating(){
        indicatorView.startAnimating()
        self.containerView.alpha = 0
        self.indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
        self.backgroundColor = .clear
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 1
            self.indicatorView.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        } completion: { (_) in}
    }
    
    public func stopAnimating(){
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.containerView.alpha = 0
            self.indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
            self.backgroundColor = .clear
        } completion: { (_) in
            self.indicatorView.stopAnimating()
            self.containerView.alpha = 1
            self.indicatorView.transform = .identity
            self.removeFromSuperview()
        }
    }
    
    func setLabel(_ text:String){
        label.text = text
        layoutIfNeeded()
    }
    
    //MARK:-private
    private func initUI() {
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .systemGray2, padding: .zero)
        
        //提示lable
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "DIN Alternate", size: 10)
        label.textColor = .systemGray
        label.numberOfLines = 0
        
        //模糊视图
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //指示器+模糊视图的容器视图
        containerView = UIView()
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(indicatorView)
        containerView.addSubview(progressView)
        containerView.addSubview(label)
        self.addSubview(containerView)
        
    }
    
    //MARK:-设置约束(protected)
    func setBaseConstrains(){
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        
        label.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(60)
            make.bottom.equalToSuperview()
            make.left.greaterThanOrEqualTo(containerView).offset(10)
            make.right.lessThanOrEqualTo(containerView).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        //indicatorView和progressView的布局暂时先不初始化
        //等确定了指示器类型（菊花or进度条）后再布局，这样就可以“撑起”containerView
        
    }
}
