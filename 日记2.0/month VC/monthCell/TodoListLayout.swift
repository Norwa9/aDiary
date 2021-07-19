//
//  TodoListLayout.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

let kTodoListLineSpacing:CGFloat = 5
let kTodoListItemHeight:CGFloat = 30

class TodoListLayout: UICollectionViewLayout {
    var dataSource:[String]!
    
    var inset:UIEdgeInsets = layoutParasManager.shared.collectionEdgesInset
    var totalHeight:CGFloat!
    var itemWidth:CGFloat{
        get{
            return layoutParasManager.shared.todoListItemWidth
        }
    }
    private var lineSpacing:CGFloat = kTodoListLineSpacing
    private var itemHeight:CGFloat = kTodoListItemHeight
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        let itemNum = dataSource.count
        totalHeight = (itemHeight + lineSpacing) * CGFloat(itemNum)
        self.layoutAttributesArray = calculateLayoutAttributesArray(itemNum: itemNum)
        
    }
    
    func calculateLayoutAttributesArray(itemNum:Int) -> [UICollectionViewLayoutAttributes]{
        var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
        let leftInset = self.inset.left
        for index in 0..<itemNum{
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = CGRect(x: leftInset,
                                           y: (self.lineSpacing + self.itemHeight) * CGFloat(index) + self.lineSpacing / 2,
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
