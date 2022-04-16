//
//  editorAnimator.swift
//  日记2.0
//
//  Created by 罗威 on 2021/10/23.
//

import Foundation
import UIKit

class editorAnimator:NSObject,UIViewControllerAnimatedTransitioning{
    var duration = 0.7
    var animationType:AnimationType!
    var toFrame:CGRect?
    var fromFrame:CGRect?
    var fromCell:CGRect?
    var cell:monthCell?
    
    override init() {
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if animationType == .present{
            animationForPresent(using: transitionContext)
        }else{
            animationForDismiss(using: transitionContext)
        }
    }
    
    //一、展示
    func animationForPresent(using transitionContext: UIViewControllerContextTransitioning){
        let containerView = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: .to) as? todayVC else{
            return
        }
        containerView.addSubview(toVC.view)
        toVC.view.frame = CGRect(origin: .zero, size: globalConstantsManager.shared.appSize)
        toVC.view.frame.origin.y = 1500
        toVC.view.transform = CGAffineTransform(scaleX: 0.90, y: 1)
        //toVC.view.layer.cornerRadius = 20
        //toVC.subpagesView.layer.cornerRadius = 20
        //3.change original size to final size with animation
        UIView.animate(withDuration: duration + 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            toVC.view.frame.origin.y = 0
            toVC.view.transform = .identity
            //toVC.subpagesView.layer.cornerRadius = 0
        } completion: { (completed) in
            print(toVC.view.frame)
            transitionContext.completeTransition(completed)
        }
    }
    
    //二、回收
    func animationForDismiss(using transitionContext: UIViewControllerContextTransitioning){
        //1.get fromVC and toVC
        guard let fromVC = transitionContext.viewController(forKey: .from) as? todayVC else {return}
        
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            fromVC.view.frame.origin.y = globalConstantsManager.shared.kScreenHeight + 100
        } completion: { (completed) in
            fromVC.view.frame.origin.y = 0
            transitionContext.completeTransition(completed)
        }
        
    }
}
