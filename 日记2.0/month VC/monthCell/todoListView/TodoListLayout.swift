//
//  TodoListLayout.swift
//  日记2.0
//
//  Created by yy on 2021/7/19.
//

import UIKit

class TodoListLayout: UICollectionViewLayout {
    var dataSource:[LWTodoViewModel]!
    
    var insetX:CGFloat = layoutParasManager.shared.todoListCellInset.left
    var totalHeight:CGFloat = 0
    var itemWidth:CGFloat{
        get{
            return layoutParasManager.shared.todoListItemWidth
        }
    }
    private var lineSpacing:CGFloat = layoutParasManager.shared.todoListLineSpacing
    private var itemHeights:[CGFloat]{
        get{
            // itemHeights 必须设置成getter计算属性
            // 否者itemHeights会跟不上dataSource的更新速度，造成数组溢出崩溃
            return dataSource.map { viewModel in
                viewModel.calSingleRowTodoViewHeihgt()
            }
        }
    }
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        layoutAttributesArray = []
        let itemNum = dataSource.count
        if itemNum>0{
            totalHeight = 0
            for h in itemHeights{
                totalHeight += h
            }
            totalHeight += (lineSpacing) * CGFloat(itemNum) + lineSpacing
        }else{
            totalHeight = 0
        }
        self.layoutAttributesArray = calculateLayoutAttributesArray(itemNum: itemNum)
        
    }
    
    func calculateLayoutAttributesArray(itemNum:Int) -> [UICollectionViewLayoutAttributes]{
        var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
        for index in 0..<itemNum{
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            var YofIndex = 0.0
            for i in 0..<index{
                YofIndex += itemHeights[i]
            }
            layoutAttribute.frame = CGRect(x: self.insetX,
                                           y: self.lineSpacing * CGFloat(index) + YofIndex + self.lineSpacing,
                                           width: self.itemWidth,
                                           height: self.itemHeights[index])
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
