//
//  layoutParasManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/12.
//

import Foundation
import UIKit

class layoutParasManager: NSObject {
    private let layoutUserDefault:UserDefaults = UserDefaults(suiteName: "layout.default")!
    static let shared = layoutParasManager()
    
    ///与布局有关的全局变量
    let collectionEdgesInset = UIEdgeInsets(top: 45, left: 10, bottom: 50, right: 10)
    
    var collectioncolumnNumber:Int{
        get{
            return userDefaultManager.layoutType
        }
        set{
            userDefaultManager.layoutType = newValue
        }
    }
    
    let collectionInteritemSpacing:CGFloat = 10
    let collectionLineSpacing:CGFloat = 10
    
    ///collectionview的宽度
    private var contentWidth:CGFloat{
        get{
            return UIScreen.main.bounds.width - collectionEdgesInset.left - collectionEdgesInset.right
        }
    }
    
    ///monthCell的宽度
    var itemWidth:CGFloat{
        //设置getter方法，每次访问KitemWidth总能获得最新的值
        get{
            return (contentWidth -  CGFloat((collectioncolumnNumber - 1)) * collectionInteritemSpacing ) / CGFloat(collectioncolumnNumber)
        }
    }
    
    
    //MARK:-todo list paras
    ///todo list CollectionView的宽度
    let todoListLineSpacing:CGFloat = 5
    let todoListItemHeight:CGFloat = 30
    
    var todoListViewWidth:CGFloat{
        get{
            return self.itemWidth - 10.0 - 10.0
        }
    }
    
    ///内部cell的inset
    var todoListCellInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    ///todo list cell的宽度
    var todoListItemWidth:CGFloat{
        get{
            return self.todoListViewWidth - todoListCellInset.left - todoListCellInset.right
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
