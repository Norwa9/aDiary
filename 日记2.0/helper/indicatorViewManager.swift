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
    
    //高斯模糊图层
    let blurEffectView:UIVisualEffectView!
    
    //容器图层
    let indicatorViewContainer:UIView!
    
    init() {
        //实例化
        indicatorView = NVActivityIndicatorView(frame: .zero, type: .lineSpinFadeLoader, color: .lightGray, padding: .zero)
        
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        indicatorViewContainer = UIView(frame: UIScreen.main.bounds)
        
        indicatorViewContainer.addSubview(blurEffectView)
        indicatorViewContainer.addSubview(indicatorView)
        
        //约束
        indicatorView.snp.makeConstraints { make in
            make.edges.equalTo(self.indicatorViewContainer)
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self.indicatorViewContainer)
        }
    }
    
    ///开始显示菊花
    func start(){
        DispatchQueue.main.async {
            let topWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
            topWindow.addSubview(self.indicatorViewContainer)
            self.indicatorView.startAnimating()
        }
        
    }
    
    ///结束显示菊花
    func stop(){
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
            self.indicatorViewContainer.removeFromSuperview()
        }
    }
    
}
