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
    
    var topWindow:UIWindow?{
        get{
            return UIApplication.getTopWindow()
        }
    }
    var indicatorView:LWCustomIndicatorView?
    var isShowingIndicator = false{
        didSet{
            // topWindow?.isUserInteractionEnabled = !isShowingIndicator
        }
    }
    
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
        if !userDefaultManager.iCloudEnable{
            return
        }
        DispatchQueue.main.async { [self] in
            if isShowingIndicator {
                print("isShowingIndicator")
                return
            }
            indicatorView = indicatorFactory(type: type)
            if let topWindow = topWindow,
               let indicatorView = indicatorView
            {
                topWindow.addSubview(indicatorView)
                indicatorView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                //开始转
                indicatorView.present()
                isShowingIndicator = true
            }
            
        }
        
    }
    
    ///关闭指示器
    public func stop(withText:String? = nil){
        if !userDefaultManager.iCloudEnable{
            return
        }
        DispatchQueue.main.async {[self] in
                //错误结束转动
            if let text = withText,let indicatorView = indicatorView{
                indicatorView.setLabel(text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    indicatorView.dismiss()
                }
            }else{
                //正常结束转动
                indicatorView?.dismiss()
            }
            isShowingIndicator = false
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
            indicatorView.setLabel("正在同步...")
        case .fetchRemoteChange:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("检测到修改...")
        case .delete:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("正在删除...")
        case .recover:
            indicatorView =  LWDefaultIndicatorView()
            indicatorView.setLabel("正在同步...")
        default:
            indicatorView =  LWDefaultIndicatorView()
        }
        return indicatorView
    }
}
