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
    
    var topWindow:UIWindow{
        get{
            return UIApplication.getTopWindow()
        }
    }
    var indicatorView:LWCustomIndicatorView = LWCustomIndicatorView()
    
    ///进度
    var progress:Float = 0{
        didSet{
            indicatorView.setProgress(progress: progress)
//            DispatchQueue.main.async {
//                print("progress:\(self.progress)")
//                self.progressView.setProgress(self.progress, animated: true)
//            }
        }
    }
    //MARK:-public
    ///开始显示菊花
    public func start(type:indicatorType){
        DispatchQueue.main.async { [self] in
            topWindow.isUserInteractionEnabled = false
            if topWindow.subviews.contains(self.indicatorView){
                print("contains(self.containerView)")
                return
            }
            topWindow.addSubview(indicatorView)
            indicatorView.configureSubviews(withType: type)
            
            //开始转
            self.indicatorView.startAnimating()
        }
        
    }
    
    ///结束显示菊花
    public func stop(){
        DispatchQueue.main.async {[self] in
            topWindow.isUserInteractionEnabled = true
            
            //结束转动
            self.indicatorView.stopAnimating()
        }
    }
    
    //MARK:-public
}
