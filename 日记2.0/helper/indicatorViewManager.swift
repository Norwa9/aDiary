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
            UIView.animate(withDuration: 0.1) {
                self.progressView.progress = self.progress
            }
        }
    }
    
    ///菊花指示器图层
    let indicatorView:NVActivityIndicatorView!
    
    ///高斯模糊图层
    let blurEffectView:UIVisualEffectView!
    
    ///容器图层
    let containerView:UIView!
    
    ///指示器的样式
    enum Style:Int{
        case banner //顶部横幅
        case center //显示在中部
        case export //导出
    }
    
    init() {
        //进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        progressView.alpha = 0
        
        //菊花条视图
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        
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
    
    ///开始显示菊花
    func start(style:Style = .center){
        DispatchQueue.main.async { [self] in
            if topWindow.subviews.contains(self.containerView){
                return
            }
            topWindow.addSubview(self.containerView)
            
            ///根据样式更新约束
            updateView(style: style)
            
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
    
    private func updateView(style:Style){
        self.containerView.snp.removeConstraints()
        switch style{
        ///底部
        case .banner:
            self.containerView.snp.makeConstraints { (make) in
                make.bottom.equalTo(topWindow).offset(-50)
                make.centerX.equalTo(topWindow)
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
            break
        ///正中央
        case .center:
            self.containerView.snp.makeConstraints { (make) in
                make.center.equalTo(topWindow)
                make.size.equalTo(CGSize(width: 60, height: 60))
            }
            break
        ///导出模式
        case .export:
            progressView.progress = 0
            progressView.alpha = 1
            indicatorView.alpha = 0
            self.containerView.snp.makeConstraints { (make) in
                make.center.equalTo(topWindow)
                make.size.equalTo(CGSize(width: 200, height: 20))
            }
            break
        }
    }
    
    ///结束显示菊花
    func stop(){
        DispatchQueue.main.async {
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
    
}
