//
//  sharePresentVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit
class blurPresentationController: UIPresentationController {
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    private lazy var blurView = UIVisualEffectView(effect: nil)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        let container = containerView!
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blurView)
        blurView.edges(to: container)
        blurView.alpha = 0.0
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurView.addGestureRecognizer(tapGestureRecognizer)
        
        presentingViewController.beginAppearanceTransition(false, animated: false)
        presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) in
            self.blurView.effect = UIBlurEffect(style: .dark)
            self.blurView.alpha = 1
        }) { (ctx) in }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect{
        return globalConstantsManager.shared.kBoundsFrameOfShareView
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.beginAppearanceTransition(true, animated: true)
        presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) in
            self.blurView.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
        if completed {
            blurView.removeFromSuperview()
        }
    }
    
    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
