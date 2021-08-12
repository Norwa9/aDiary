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
        }
    }
    //MARK:-public
    ///展示指示器
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
            indicatorView.present()
        }
        
    }
    
    ///关闭指示器
    public func stop(errorText:String? = nil){
        DispatchQueue.main.async {[self] in
            topWindow.isUserInteractionEnabled = true
            
                //错误结束转动
            if let text = errorText{
                indicatorView.setLabel(text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    indicatorView.dismiss()
                }
            }else{
                //正常结束转动
                indicatorView.dismiss()
            }
        }
    }
    
    //MARK:-private
    ///实例化LWCustomIndicatorView的子类对象
    private func indicatorFactory(type:indicatorType) -> LWCustomIndicatorView{
        var indicatorView:LWCustomIndicatorView
        switch type {
        case .progress:
            indicatorView = LWProgressView()
            indicatorView.setLabel("正在导出...")
        case .checkRemoteChange:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("正在获取云端数据变动\n(如果网络状况不佳，可重启App重试)")
        case .fetchRemoteChange:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("检测到其它设备的修改，正在同步...")
        default:
            indicatorView =  LWDefaultIndicatorView()
        }
        return indicatorView
    }
}
