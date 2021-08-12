//
//  indicatorViewManager.swift
//  日记2.0
//
//  Created by yy on 2021/7/13.
//

import Foundation
import UIKit
import NVActivityIndicatorView

///菊花指示器助手
class indicatorViewManager{
    static let shared = indicatorViewManager()
    
    var topWindow:UIWindow {
        get{
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        }
    }
    ///进度条
    let progressView:UIProgressView!
    ///进度
    var progress:Float = 0{
        didSet{
            print("progress:\(self.progress)")
            self.progressView.setProgress(self.progress, animated: true)
//            DispatchQueue.main.async {
//                print("progress:\(self.progress)")
//                self.progressView.setProgress(self.progress, animated: true)
//            }
        }
    }
    
    ///菊花指示器图层
    let indicatorView:NVActivityIndicatorView!
    
    ///高斯模糊图层
    let blurEffectView:UIVisualEffectView!
    
    ///指示器的容器图层
    let containerView:UIView!
    
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
    //MARK:-public
    ///开始显示菊花
    public func start(type:indicatorType){
        DispatchQueue.main.async { [self] in
            topWindow.isUserInteractionEnabled = false
            if topWindow.subviews.contains(self.containerView){
                print("contains(self.containerView)")
                return
            }
            topWindow.addSubview(self.containerView)
            
            ///根据样式更新约束
            updateView(style: type)
            
            //开始转
            self.indicatorView.startAnimating()
            self.blurEffectView.alpha = 0
            self.indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
                self.blurEffectView.alpha = 1
                self.indicatorView.transform = .identity
            } completion: { (_) in}
        }
        
    }
    
    ///结束显示菊花
    public func stop(){
        DispatchQueue.main.async {[self] in
            topWindow.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
                self.blurEffectView.alpha = 0
                self.indicatorView.transform = .init(scaleX: 0.01, y: 0.01)
            } completion: { (_) in
                self.indicatorView.stopAnimating()
                self.blurEffectView.alpha = 1
                self.indicatorView.transform = .identity
                self.containerView.removeFromSuperview()
            }
            
            
        }
    }
    
    //MARK:-private
    private init() {
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        progressView.alpha = 0
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .systemGray2, padding: .zero)
        
        //模糊视图
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //底部容器视图
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(indicatorView)
        containerView.addSubview(progressView)
        
        
        setConstrains()
    }
    
    //MARK:-设置约束
    private func setConstrains(){
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
    }
    
    
    //MARK:-根据type配置不同的indicator view
    private func updateView(style:indicatorType){
        self.containerView.snp.removeConstraints()
        switch style{
//        ///底部
//        case .checkRemoteChange:
//            progressView.alpha = 0
//            indicatorView.alpha = 1
//            self.containerView.snp.makeConstraints { (make) in
//                make.bottom.equalTo(topWindow).offset(-50)
//                make.centerX.equalTo(topWindow)
//                make.size.equalTo(CGSize(width: 50, height: 50))
//            }
//            break
        ///正中央
        case .fetchRemoteChange,.checkRemoteChange,.iap,.other:
            progressView.alpha = 0
            indicatorView.alpha = 1
            self.containerView.snp.makeConstraints { (make) in
                make.center.equalTo(topWindow)
                make.size.equalTo(CGSize(width: 60, height: 60))
            }
            break
        ///进度条
        case .progress:
            progressView.progress = 0
            progressView.alpha = 1
            indicatorView.alpha = 0
            self.containerView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(300)
                make.size.equalTo(CGSize(width: 200, height: 20))
            }
            break
        }
    }
    
    
    
}
