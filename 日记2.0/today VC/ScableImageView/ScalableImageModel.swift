//
//  ScableImageModel.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView
import RealmSwift

class ScalableImageModel:NSObject,Codable {
    @objc dynamic var location:Int = -1
    @objc dynamic var imageData:Data? = nil
    @objc dynamic var bounds:String = ""
    @objc dynamic var paraStyle:Int = -1
    @objc dynamic var contentMode:Int = -1
    
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
