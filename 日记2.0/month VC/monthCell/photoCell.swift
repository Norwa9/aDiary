//
//  photoCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/5/29.
//

import UIKit
import SnapKit

class photoCell: UICollectionViewCell {
    static let photoCellID = "photoCell"
    
    var photo:UIImage!{
        didSet{
            photoPreviewView.image = photo
        }
    }
    var photoPreviewView:UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        //UI设置
        photoPreviewView = UIImageView()
        photoPreviewView.contentMode = .scaleAspectFill
        photoPreviewView.layer.cornerRadius = 10
        photoPreviewView.clipsToBounds = true
        photoPreviewView.layer.borderWidth = 2
        photoPreviewView.layer.borderColor = UIColor.lightGray.cgColor
        self.addSubview(photoPreviewView)
        
    }
    
    func setupConstraints(){
        //约束
        photoPreviewView.snp.makeConstraints { (make) in
            make.size.equalTo(self)
        }
    }
    
}
