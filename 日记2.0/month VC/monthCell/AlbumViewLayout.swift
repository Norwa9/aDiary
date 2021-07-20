//
//  AlbumViewLayout.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/20.
//

import UIKit

class AlbumViewLayout: UICollectionViewFlowLayout {
    var itemNum:Int = 0
    
    private var insetX:CGFloat = layoutParasManager.shared.albumViewCellInset.left
    private var insetY:CGFloat = layoutParasManager.shared.albumViewCellInset.top
    
    var totalWidth:CGFloat!
    var totalHeight:CGFloat!
    
    private var itemWidth:CGFloat{
        get{
            return layoutParasManager.shared.albumViewItemWidth
        }
    }
    private var itemHeight:CGFloat{
        get{
            return layoutParasManager.shared.albumViewItemHeight
        }
    }
    
    private var lineSpacing:CGFloat = layoutParasManager.shared.albumViewLineSpacing
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        if itemNum>0{
            let contentWith = (itemWidth + lineSpacing) * CGFloat(itemNum) + lineSpacing
            totalWidth = max(contentWith, layoutParasManager.shared.albumViewWidth)
            totalHeight = layoutParasManager.shared.albumViewHeight
        }else{
            totalWidth = 0
            totalHeight = 0
        }
        self.layoutAttributesArray = calculateLayoutAttributesArray(itemNum: itemNum)
        
    }
    
    func calculateLayoutAttributesArray(itemNum:Int) -> [UICollectionViewLayoutAttributes]{
        var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
        for index in 0..<itemNum{
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = CGRect(x: (self.lineSpacing + self.itemWidth) * CGFloat(index) + self.lineSpacing,
                                           y: insetY,
                                           width: self.itemWidth,
                                           height: self.itemHeight)
            layoutAttributesArray.append(layoutAttribute)
        }
        return layoutAttributesArray
    }
    
}

//MARK:-override
extension AlbumViewLayout{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributesArray
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: self.totalWidth, height: self.totalHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.layoutAttributesArray[indexPath.item]
    }
}
