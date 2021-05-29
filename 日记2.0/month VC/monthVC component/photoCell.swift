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
    var photoPreviewView:UIImageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        //UI设置
        photoPreviewView.contentMode = .scaleAspectFill
        photoPreviewView.layer.cornerRadius = 10
        photoPreviewView.layer.borderWidth = 1
        photoPreviewView.clipsToBounds = true
        photoPreviewView.layer.borderColor = APP_GRAY_COLOR().cgColor
        self.addSubview(photoPreviewView)
        //约束
        photoPreviewView.snp.makeConstraints { (make) in
            make.size.equalTo(self)
        }
    }
}
