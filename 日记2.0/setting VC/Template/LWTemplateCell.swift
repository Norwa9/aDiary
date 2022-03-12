//
//  LWTemplateCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

class LWTemplateCell: UICollectionViewCell {
    static let reuseID = "LWTemplateCell"
    private var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewModel(){
        self.initUI()
        self.setCons()
    }
    
    private func initUI(){
        imageView = UIImageView(image: UIImage(named: "diaryIcon"))
        self.addSubview(imageView)
    }
    
    private func setCons(){
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
