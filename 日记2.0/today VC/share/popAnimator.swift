//
//  popAnimator.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit
enum AnimationType{
    case present
    case dismiss
}

class PopAnimator:NSObject,UIViewControllerAnimatedTransitioning{
    var duration = 0.8
    var animationType:AnimationType!
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
        guard let toVC = transitionContext.viewController(forKey: .to) as? shareVC else{
            return
        }
        containerView.addSubview(toVC.view)
        toVC.view.frame = globalConstantsManager.shared.kBoundsFrameOfShareView
        toVC.view.frame.origin.y = -1000
        //3.change original size to final size with animation
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.curveEaseInOut,.allowUserInteraction]) {
            toVC.view.frame.origin.y = globalConstantsManager.shared.kBoundsFrameOfShareView.origin.y
        } completion: { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
    //二、回收
    func animationForDismiss(using transitionContext: UIViewControllerContextTransitioning){
        //1.get fromVC and toVC
        guard let fromVC = transitionContext.viewController(forKey: .from) as? shareVC else {return}
        
        UIView.animate(withDuration: duration - 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
            
            fromVC.view.frame.origin.y = globalConstantsManager.shared.kScreenHeight + 100
        }) { (completed) in
            transitionContext.completeTransition(completed)
            
        }
        
    }
}
