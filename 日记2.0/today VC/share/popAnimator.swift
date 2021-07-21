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
        //1.get fromVC and toVC
        guard let fromVC = transitionContext.viewController(forKey: .to) as? todayVC else{
            print("1")
            return
        }
        guard let toVC = transitionContext.viewController(forKey: .to) as? shareVC else{
            return
        }
        containerView.addSubview(toVC.view)
        
        //2.set presentation original size
//        let fromFrame = fromVC.view.convert(fromVC.textView.frame, to: rootVC.view)
//        toVC.view.frame = fromFrame
//        toVC.view.clipsToBounds = true
        
        
        let topbarLabelFrame:CGRect = .zero
        let fromtextViewFrame = fromVC.textView.frame
        let imageViewFrame = toVC.scrollView.textImageView.frame
        let scaleRation = blurPresentationController.frameOfPresentedView.width / fromtextViewFrame.width//<1
        toVC.view.frame = blurPresentationController.frameOfPresentedView
        toVC.view.frame.origin.y = -1000
        //3.change original size to final size with animation
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.curveEaseInOut,.allowUserInteraction]) {
            toVC.view.frame.origin.y = blurPresentationController.frameOfPresentedView.origin.y
        } completion: { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
    //二、回收
    func animationForDismiss(using transitionContext: UIViewControllerContextTransitioning){
        //1.get fromVC and toVC
        guard let fromVC = transitionContext.viewController(forKey: .from) as? shareVC else {return}
        guard let toVC = transitionContext.viewController(forKey: .to) as? todayVC else{
            print("2")
            return
        }
        
        let toTextViewFrame = toVC.textView.frame
        
        UIView.animate(withDuration: duration - 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
            
            fromVC.view.frame.origin.y = 1000
//            fromVC.view.frame.size.height = 0
//            fromVC.scrollView.imageView.frame = toTextViewFrame
//            fromVC.scrollView.dateLabel.alpha = 0
        }) { (completed) in
            transitionContext.completeTransition(completed)
            
        }
        
    }
}
