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
    
    ///菊花指示器图层
    let indicatorView:NVActivityIndicatorView!
    
    ///高斯模糊图层
    let blurEffectView:UIVisualEffectView!
    
    ///容器图层
    let containerView:UIView!
    
    ///指示器的样式
    enum style:Int{
        case banner //顶部横幅
        case center //显示在中部
    }
    
    init() {
        //实例化
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(blurEffectView)
        containerView.addSubview(indicatorView)
        
        //约束
        indicatorView.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView)
        }
    }
    
    ///开始显示菊花
    func start(style:style = .center){
        DispatchQueue.main.async {
            let topWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
            if topWindow.subviews.contains(self.containerView){
                return
            }
            topWindow.addSubview(self.containerView)
            
            ///根据样式更新约束
            self.containerView.snp.removeConstraints()
            self.containerView.snp.makeConstraints { (make) in
                switch style{
                case .banner:
                    make.bottom.equalTo(topWindow).offset(-50)
                    make.centerX.equalTo(topWindow)
                    make.size.equalTo(CGSize(width: 50, height: 50))
                case .center:
                    make.center.equalTo(topWindow)
                    make.size.equalTo(CGSize(width: 60, height: 60))
                }
                
            }
            
            
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
