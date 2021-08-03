//
//  AlbumView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/31.
//

import UIKit

class AlbumView: UIView {
    var layout:UICollectionViewFlowLayout
    var collectionView:UICollectionView
    
    init(model:diaryInfo) {
        self.layout = AlbumViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        super.init(frame: .zero)
        
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

