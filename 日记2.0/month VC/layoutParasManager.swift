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
    let collectionEdgesInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    var collectioncolumnNumber:Int{
        get{
            return userDefaultManager.layoutType
        }
        set{
            userDefaultManager.layoutType = newValue
        }
    }
    
    let collectionInteritemSpacing:CGFloat = 10
    let collectionLineSpacing:CGFloat = 15
    
    ///collectionview的宽度
    private var contentWidth:CGFloat{
        get{
            return globalConstantsManager.shared.kScreenWidth - collectionEdgesInset.left - collectionEdgesInset.right
        }
    }
    
    ///monthCell的宽度
    var monthCellWidth:CGFloat{
        //设置getter方法，每次访问KitemWidth总能获得最新的值
        get{
            return (contentWidth -  CGFloat((collectioncolumnNumber - 1)) * collectionInteritemSpacing ) / CGFloat(collectioncolumnNumber)
        }
    }
    
    
    //MARK:-todo list paras
    let todoListLineSpacing:CGFloat = 1
    
    ///todo list CollectionView的宽度
    private var todoListViewWidth:CGFloat{
        get{
            return self.monthCellWidth - 10.0 - 10.0
        }
    }
    
    ///内部cell的inset
    var todoListCellInset = UIEdgeInsets(top: 0, left: 2.5, bottom: 0, right: 2.5)
    
    ///todo list cell的宽度
    var todoListItemWidth:CGFloat{
        get{
            return self.todoListViewWidth - todoListCellInset.left - todoListCellInset.right
        }
    }
    
    //MARK:-album view paras
    let albumViewLineSpacing:CGFloat = 5
    ///内部cell的inset
    let albumViewCellInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    ///album CollectionView的宽度
    var albumViewWidth:CGFloat{
        get{
            return self.monthCellWidth//15.0 albumView距离containerView的边界
        }
    }
    
    ///一个cell的宽度能显示的照片数量
    var albumItemToShow:Int{
        get{
            return 3
        }
    }
    
    ///album View cell的宽度
    var albumViewItemWidth:CGFloat{
        get{
            return (albumViewWidth - albumViewCellInset.left - albumViewCellInset.right - CGFloat(albumItemToShow - 1) * albumViewLineSpacing) / CGFloat(albumItemToShow)
        }
    }
    
    ///album View cell的高度
    var albumViewItemHeight:CGFloat{
        get{
            return self.albumViewItemWidth
        }
    }
    
    var albumViewHeight:CGFloat{
        get{
            return self.albumViewItemHeight + 2 * albumViewCellInset.top
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
