//
//  shareScrollView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import Foundation
import UIKit

class shareScrollView:UIScrollView{
    let dateLabel = UILabel()
    let imageView = UIImageView()
    let signature = UILabel()
    var snapshot:UIImage
    var diary:diaryInfo
    
    init(frame: CGRect,snapshot:UIImage,diary:diaryInfo) {
        self.snapshot = snapshot
        self.diary = diary
        super.init(frame: frame)
        setupUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = false
        
        let scrollViewWidth = blurPresentationController.frameOfPresentedView.size.width
        dateLabel.frame = CGRect(x: 0, y: 0, width: 195, height: 33)
        dateLabel.center.x = scrollViewWidth / 2
        dateLabel.textAlignment = .center
        dateLabel.text = diary.date
        dateLabel.font = appDefaultFonts.dateLable1Font
        
        let scrollimageHeight = snapshot.size.height / snapshot.size.width * scrollViewWidth
        imageView.frame = CGRect(x: 0, y: dateLabel.frame.height, width: scrollViewWidth, height: scrollimageHeight)
        imageView.contentMode = .scaleAspectFill
        imageView.image = snapshot
        
        
        signature.frame = CGRect(x: 0, y: dateLabel.frame.height + imageView.frame.height, width: scrollViewWidth, height: 20)
        
        self.addSubview(dateLabel)
        self.addSubview(imageView)
        self.addSubview(signature)
        
        contentSize = CGSize(width: scrollViewWidth, height: dateLabel.frame.height + imageView.frame.height + signature.frame.height)
    }
    
}
