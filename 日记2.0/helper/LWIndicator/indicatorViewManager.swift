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
    var indicatorView:LWCustomIndicatorView!
    
    ///进度
    var progress:Float = 0{
        didSet{
            if let progressView = indicatorView as? LWProgressView{
                progressView.setProgress(progress: progress)
            }
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
            for subView in topWindow.subviews{
                if ((subView as? LWCustomIndicatorView) != nil){
                    return
                }
            }
            indicatorView = indicatorFactory(type: type)
            topWindow.addSubview(indicatorView)
            indicatorView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            //开始转
            indicatorView.startAnimating()
        }
        
    }
    
    ///结束显示菊花
    public func stop(){
        DispatchQueue.main.async {[self] in
            topWindow.isUserInteractionEnabled = true
            
            //结束转动
            indicatorView.stopAnimating()
        }
    }
    
    //MARK:-private
    private func indicatorFactory(type:indicatorType) -> LWCustomIndicatorView{
        var indicatorView:LWCustomIndicatorView
        switch type {
        case .progress:
            indicatorView = LWProgressView()
            indicatorView.setLabel("正在导出...")
        default:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("正在云同步。\n为了保证数据安全，请勿操作。")
        }
        return indicatorView
    }
}
