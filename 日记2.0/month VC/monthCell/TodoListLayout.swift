//
//  TodoListLayout.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListLayout: UICollectionViewLayout {
    var dataSource:[String]!
    
    var insetX:CGFloat = layoutParasManager.shared.todoListCellInset.left
    var totalHeight:CGFloat!
    var itemWidth:CGFloat{
        get{
            return layoutParasManager.shared.todoListItemWidth
        }
    }
    private var lineSpacing:CGFloat = layoutParasManager.shared.todoListLineSpacing
    private var itemHeight:CGFloat = layoutParasManager.shared.todoListItemHeight
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        layoutAttributesArray = []
        let itemNum = dataSource.count
        if itemNum>0{
            totalHeight = (itemHeight + lineSpacing) * CGFloat(itemNum) + lineSpacing
        }else{
            totalHeight = 0
        }
        self.layoutAttributesArray = calculateLayoutAttributesArray(itemNum: itemNum)
        
    }
    
    func calculateLayoutAttributesArray(itemNum:Int) -> [UICollectionViewLayoutAttributes]{
        var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
        for index in 0..<itemNum{
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = CGRect(x: self.insetX,
                                           y: (self.lineSpacing + self.itemHeight) * CGFloat(index) + self.lineSpacing,
                                           width: self.itemWidth,
                                           height: self.itemHeight)
            layoutAttributesArray.append(layoutAttribute)
        }
        return layoutAttributesArray
    }
    
}

//MARK:-override
extension TodoListLayout{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributesArray
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: self.itemWidth, height: self.totalHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.layoutAttributesArray[indexPath.item]
    }
}
