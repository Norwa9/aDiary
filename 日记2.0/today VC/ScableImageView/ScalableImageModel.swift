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

class ScalableImageModel:NSObject, Codable, YYModel {
    @objc dynamic var location:Int = -1//ScalableImageModel在attributedText的下标
    @objc dynamic var bounds:String = ""//ScalableImageView的bounds
    @objc dynamic var viewScale:CGFloat = 0//imageView宽度与屏幕宽度比例
    @objc dynamic var paraStyle:Int = 0//center
    @objc dynamic var contentMode:Int = 2//aspectFill
    @objc dynamic var uuid:String = "" // 索引图像数据的唯一标识符
    
    override init() {
        super.init()
    }
    
    init(location:Int,bounds:CGRect,paraStyle:Int,contentMode:Int,uuid:String = "") {
        self.location = location
        
        let boundsSring = "\(bounds.origin.x),\(bounds.origin.y),\(bounds.size.width),\(bounds.size.height)"
        self.bounds = boundsSring
        
        self.viewScale = bounds.width / globalConstantsManager.shared.kScreenWidth
        
        self.paraStyle = paraStyle
        self.contentMode = contentMode
        self.uuid = uuid
        super.init()
    }
    
    
    
    
}
