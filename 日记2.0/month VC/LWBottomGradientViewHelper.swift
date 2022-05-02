//
//  LWBottomGradientViewHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import UIKit

class LWBottomGradientViewHelper{
    static let shared = LWBottomGradientViewHelper()
    let kBlurEffectViewHeight:CGFloat = 120
    
    /// 获取底部渐变图层
    func getBottomGradientView()->UIVisualEffectView{
        let blurEffectView:UIVisualEffectView
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
        if UITraitCollection.current.userInterfaceStyle == .dark{
            blurEffectView.alpha = 0
        }else{
            blurEffectView.alpha = 1
        }
        
        blurEffectView.frame = CGRect(
            x:0,
            y:globalConstantsManager.shared.kScreenHeight - kBlurEffectViewHeight,
            width: globalConstantsManager.shared.kScreenWidth,
            height: kBlurEffectViewHeight);
        let gradientLayer = CAGradientLayer()//底部创建渐变层
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.label.cgColor]
        gradientLayer.frame = blurEffectView.bounds
        gradientLayer.locations = [0,0.9,1]
        blurEffectView.layer.mask = gradientLayer
        return blurEffectView
    }
    
    func getTopBlurEffectView()->UIVisualEffectView{
        let blurEffectView:UIVisualEffectView
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
        if UITraitCollection.current.userInterfaceStyle == .dark{
            blurEffectView.alpha = 0
        }else{
            blurEffectView.alpha = 1
        }
        
        blurEffectView.frame = CGRect(
            x:0,
            y:0,
            width: globalConstantsManager.shared.kScreenWidth,
            height: LWTopbarView.kTopBarViewHeight);
        let gradientLayer = CAGradientLayer()//底部创建渐变层
        gradientLayer.colors = [UIColor.label.cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.frame = blurEffectView.bounds
        gradientLayer.locations = [1,0.1,0]
        blurEffectView.layer.mask = gradientLayer
        return blurEffectView
    }
}
