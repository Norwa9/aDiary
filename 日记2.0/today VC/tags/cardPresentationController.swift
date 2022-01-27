//
//  tagsVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import UIKit

class cardPresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    let viewHeight:CGFloat = 400
    var viewWidth:CGFloat{
        get{
            return globalConstantsManager.shared.tagsVCWidth
        }
    }
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        //背景模糊视图
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(onContainerSizeChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(
                x: (self.containerView!.frame.width - viewWidth) / 2,
                y: self.containerView!.frame.height - viewHeight - 20),
               size: CGSize(
                width: self.viewWidth,
                height: self.viewHeight))
    }

    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        //显示背景视图（随着动画进度渐显）
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0.7
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        //移除背景视图
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedView!.roundCorners([.allCorners], radius: 22)//扩展
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

//MARK:-旋转屏幕
extension cardPresentationController{
    @objc private func onContainerSizeChanged(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            return
        }
        //只响应横竖的变化
        guard UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isLandscape else{
            return
        }
        //print("tagsPresentationController onContainerSizeChanged")
        //print("presentedView?.frame.size:\(presentedView?.frame.size)")
        //presentedViewController:tagsView
        //presentingViewController:monthVC
        //self.presentedView?.layoutIfNeeded()
        //self.containerView?.layoutSubviews()
        
    }
}
