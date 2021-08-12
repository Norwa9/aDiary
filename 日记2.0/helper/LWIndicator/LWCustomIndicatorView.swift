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
    //MARK:-public
    public func configureSubviews(withType type:indicatorType){
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateSubViewsCons(withType: type)
        
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
    
    ///设置进度
    public func setProgress(progress:Float){
        print("progress:\(progress)")
        self.progressView.setProgress(progress, animated: true)
    }
    
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
        label.font = UIFont(name: "DIN Alternate", size: 10)
        label.textColor = .systemGray
        label.numberOfLines = 0
        
        //模糊视图
        let blurEffect = UIBlurEffect(style: .extraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //指示器+模糊视图的容器视图
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
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
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView)
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
    
    //MARK:-根据type配置不同的indicator view的约束
    private func updateSubViewsCons(withType type:indicatorType){
        switch type{
        ///正中央
        case .fetchRemoteChange,.checkRemoteChange,.iap,.other:
            progressView.alpha = 0
            indicatorView.alpha = 1
            label.text = "正在云同步。\n为了保证数据安全，请勿操作。"
            
            indicatorView.snp.removeConstraints()
            progressView.snp.removeConstraints()
            indicatorView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 60, height: 60))
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualTo(containerView).offset(10)
                make.right.lessThanOrEqualTo(containerView).offset(-10)
                make.bottom.equalTo(label.snp.top)
            }
        ///进度条
        case .progress:
            progressView.progress = 0
            progressView.alpha = 1
            indicatorView.alpha = 0
            label.text = "正在导出..."
            
            indicatorView.snp.removeConstraints()
            progressView.snp.removeConstraints()
            progressView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 200, height: 10))
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualTo(containerView).offset(10)
                make.right.lessThanOrEqualTo(containerView).offset(-10)
                make.bottom.equalTo(label.snp.top)
            }
        }
        
        
        self.layoutIfNeeded()
    }
}
