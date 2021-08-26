//
//  ScableImageModel.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView
import YYModel

class ScalableImageModel:NSObject,YYModel {
    @objc dynamic var location:Int = -1
    @objc dynamic var bounds:String = ""
    @objc dynamic var imageScale:CGFloat = 0//高宽比
    @objc dynamic var paraStyle:Int = -1
    @objc dynamic var contentMode:Int = -1
    
    
    init(location:Int,bounds:CGRect,paraStyle:Int,contentMode:Int) {
        self.location = location
        
        let boundsSring = "\(bounds.origin.x),\(bounds.origin.y),\(bounds.size.width),\(bounds.size.height)"
        self.bounds = boundsSring
        
        self.imageScale = bounds.width / globalConstantsManager.shared.kScreenWidth
        
        self.paraStyle = paraStyle
        self.contentMode = contentMode
        super.init()
    }
    
    
    
    
}
