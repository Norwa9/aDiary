//
//  ScableImageModel.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView

class ScalableImageModel: NSObject,Codable {
    var location:Int
    var imageData:Data
    var bounds:String
    var paraStyle:Int
    var contentMode:Int
    
    init(location:Int,imageData:Data,bounds:String,paraStyle:Int,contentMode:Int) {
        self.location = location
//        self.imageData = imageData
        self.imageData = "123".data(using: .utf16)!
        self.bounds = bounds
        self.paraStyle = paraStyle
        self.contentMode = contentMode
        super.init()
    }
    
    
    
    
}
