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
    
    /// 复制一份imageModel，同时复制一份其对应的image
    func copy()->ScalableImageModel{
        let newuuid = UUID().uuidString
        let bounds = CGRect.init(string: self.bounds)
        ?? CGRect(x: 0, y: 0, width: globalConstantsManager.shared.kScreenWidth * 0.8, height: globalConstantsManager.shared.kScreenHeight * 0.8)
        let model = ScalableImageModel(location: self.location, bounds: bounds, paraStyle: self.paraStyle, contentMode: self.contentMode, uuid: newuuid)
        
        if let image = ImageTool.shared.loadImage(uuid: uuid){
            let si = scalableImage(image: image, uuid: newuuid)
            ImageTool.shared.addImages(SIs: [si]) // 创建viewModel的同时，创建它的si
        }
        
        return model
    }
    
    
    
}
