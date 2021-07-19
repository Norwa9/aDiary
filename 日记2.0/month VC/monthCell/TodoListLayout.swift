//
//  TodoListLayout.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListLayout: UICollectionViewLayout {
    var dataSource:[String]!
    var lineSpacing:CGFloat!
    var inset:UIEdgeInsets!
    var totalHeight:CGFloat!
    private var itemWidth:CGFloat!
    private var itemHeight:CGFloat!
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        let itemNum = dataSource.count
        itemWidth = layoutParasManager.shared.itemWidth - 2 * self.inset.left
        itemHeight = 20
        totalHeight = (itemHeight + lineSpacing) * CGFloat(itemNum)
        self.layoutAttributesArray = calculateLayoutAttributesArray(itemNum: itemNum)
        
    }
    
    func calculateLayoutAttributesArray(itemNum:Int) -> [UICollectionViewLayoutAttributes]{
        var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
        let leftInset = self.inset.left
        for index in 0..<itemNum{
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = CGRect(x: leftInset,
                                           y: (self.lineSpacing + self.itemHeight) * CGFloat(index),
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
