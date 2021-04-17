//
//  indictorController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/16.
//

import Foundation
import UIKit
class indictorController{
    static let shared = indictorController()
    var activityIndicator:UIActivityIndicatorView!//进度条
    init() {
        activityIndicator = UIActivityIndicatorView(style:.large)
    }
    
    func start(){
        let topVC = UIApplication.getTopViewController()
        topVC?.view.addSubview(activityIndicator)
        activityIndicator.center = (topVC?.view.center)!
        activityIndicator.startAnimating()
    }
    
    func stop(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
