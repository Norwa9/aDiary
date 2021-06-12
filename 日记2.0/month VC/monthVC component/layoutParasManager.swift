//
//  layoutParasManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/12.
//

import Foundation
import UIKit

class layoutParasManager: NSObject {
    static let shared = layoutParasManager()
    
    ///与布局有关的全局变量
    let collectionEdgesInset = UIEdgeInsets(top: 0, left: 10, bottom: 50, right: 10)
    
    var collectioncolumnNumber:Int = 2
    
    let collectionInteritemSpacing:CGFloat = 10
    let collectionLineSpacing:CGFloat = 10
    
    var contentWidth:CGFloat{
        get{
            return UIScreen.main.bounds.width - collectionEdgesInset.left - collectionEdgesInset.right
        }
    }
    
    var itemWidth:CGFloat{
        //设置getter方法，每次访问KitemWidth总能获得最新的值
        get{
            return (contentWidth -  CGFloat((collectioncolumnNumber - 1)) * collectionInteritemSpacing ) / CGFloat(collectioncolumnNumber)
        }
    }
    
    
    override init() {
        super.init()
    }
    
    ///切换展示模式（双列、单列）
    func switchLayoutMode(){
        if self.collectioncolumnNumber == 1{
            self.collectioncolumnNumber = 2
        }else{
            self.collectioncolumnNumber = 1
        }
    }
    
    
}
