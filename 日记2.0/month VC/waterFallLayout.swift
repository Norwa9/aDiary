//
//  waterFallLayout.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/11.
//

import UIKit

struct ColumnInfo
{
    ///列
    var columnNumber:Int
    ///列的总高度
    var columnHeight:CGFloat
};

/*
 自定义瀑布流布局类
 
 参考：https://segmentfault.com/a/1190000011293130
 */
class waterFallLayout: UICollectionViewFlowLayout {
    ///列间距
    var interitemSpacing:CGFloat!
    ///行间距
    var lineSpacing:CGFloat!
    ///用来计算高度的数据源
    var dateSource:[diaryInfo] = []
    ///行数
    var columnNumber:Int!
    
    private var itemWidth:CGFloat!
    
    private var viewInset:UIEdgeInsets!
    
    private var itemSizeArray:[CGSize] = []
    ///每列的总高度
    private var columnHeightArray:[CGFloat] = {
        let arr = Array.init(repeating: CGFloat(0), count: layoutParasManager.shared.collectioncolumnNumber)
        return arr
    }()
    
    private var layoutAttributesArray:[UICollectionViewLayoutAttributes] = []
    
    private var templateCell:UICollectionViewCell?
    
    override func prepare() {
        super.prepare()
        layoutAttributesArray = []
        self.columnNumber = layoutParasManager.shared.collectioncolumnNumber
        /**
         根据CollectionView宽度、列数、列间距计算Cell的宽度
         但是经过试验我发现，这里的self.itemWidth不影响实际的cell大小，
         cell的containerView的宽度约束值才是影响宽度的因子，就连下面的height也是基于containerView的宽度约束值算出来的，
         改变这里的self.itemWith不会影响height的计算
         实际上：self.itemWidth仅仅影响itemX的计算
         最好是让self.itemWidth与containerView的宽度约束值同步
         */
        self.itemWidth = layoutParasManager.shared.monthCellWidth
        ///缩进
        self.viewInset = self.collectionView!.contentInset
        self.calculateAttributesWithItemWidth(itemWidth)
    }
    
    //MARK:-布局计算
    func calculateAttributesWithItemWidth(_ itemWidth:CGFloat){
        //每次CollectionView reloadDate都会调用这个方法，因此要把以前的布局数据清空
        self.layoutAttributesArray = []
        self.columnHeightArray = Array.init(repeating: CGFloat(0), count: layoutParasManager.shared.collectioncolumnNumber)
        self.itemSizeArray = []
        
        for index in 0..<self.dateSource.count{
            let itemSize = self.calculateItemSizeWithIndex(index: index)
            let layoutAttributes = self.createLayoutAttributesWithItemSize(itemSize: itemSize, index: index)
            self.itemSizeArray.append(itemSize)
            self.layoutAttributesArray.append(layoutAttributes)
        }
    }
    
    ///计算每个item的layoutAttribute
    func createLayoutAttributesWithItemSize(itemSize:CGSize,index:Int) -> UICollectionViewLayoutAttributes{
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
        
        ///得到最短的那一列的信息（列号，列高度）
        let shortestinfo = self.shortestColumn(columnHeight: self.columnHeightArray)
        
        let itemX:CGFloat = (self.itemWidth + self.interitemSpacing) * CGFloat(shortestinfo.columnNumber)
        let itemY:CGFloat = self.columnHeightArray[shortestinfo.columnNumber] + self.lineSpacing
        
        layoutAttributes.frame = CGRect(origin: CGPoint(x: itemX, y: itemY), size: itemSize)
    
        //维护columnHeightArray（每列的总高度）
        self.columnHeightArray[shortestinfo.columnNumber] = layoutAttributes.frame.maxY
        return layoutAttributes
    }
    
    ///使用数据填充cell，然后利用其autoLayout计算其准确的高度
    func calculateItemSizeWithIndex(index:Int) ->CGSize{
        let tempCell = self.templateCellWithReuseIdentifier(reuseIdentifier: monthCell.reusableID, index: index) as! monthCell
        let diary = self.dateSource[index]
        
        tempCell.setViewModel(diary)//数据填充cell，以计算content高度
        
        let cellHeight = tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        //print("日期:\(diary.date)cellHeight:\(cellHeight)")
        return CGSize(width: self.itemWidth, height: cellHeight)
    }
    
    func templateCellWithReuseIdentifier(reuseIdentifier:String,index:Int) -> UICollectionViewCell{
        if let cell = self.templateCell{
            return cell
        }else{
            let cell = monthCell(frame: .zero)
            return cell
        }
    }
    
    ///获取最短的那一列
    func shortestColumn(columnHeight:[CGFloat])->ColumnInfo{
        var min:CGFloat = CGFloat.infinity
        var column:Int = 0
        for i in 0..<self.columnNumber{
            if(columnHeight[i] < min){
                min = columnHeight[i]
                column = i
            }
        }
        let info = ColumnInfo(columnNumber: column, columnHeight: min)
        return info
    }
    
    ///获取最高的那一列
    func highestColumn(columnHeight:[CGFloat])->ColumnInfo{
        var max:CGFloat = 0
        var column:Int = 0
        for i in 0..<self.columnNumber{
            if(columnHeight[i] > max){
                max = columnHeight[i]
                column = i
            }
        }
        let info = ColumnInfo(columnNumber: column, columnHeight: max)
        return info
    }
}

//MARK:override
extension waterFallLayout{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributesArray
    }
    
    override var collectionViewContentSize: CGSize{
//        print("collectionViewContentSize")
        let maxInfo:ColumnInfo = self.highestColumn(columnHeight: self.columnHeightArray)
        let height = maxInfo.columnHeight + self.viewInset.bottom + self.lineSpacing
        let width = self.collectionView!.bounds.size.width - self.viewInset.left - self.viewInset.right
        let extraHeight:CGFloat = 75//为了防止底部的渐变图层遮挡cell的内容
        return CGSize(width: width, height: height + extraHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesArray[indexPath.item]
    }
}
