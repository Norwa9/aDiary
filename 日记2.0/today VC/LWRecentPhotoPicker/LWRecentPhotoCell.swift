//
//  LWRecentPhotoCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/2.
//

import Foundation
import UIKit


class LWRecentPhotoCell:UICollectionViewCell{
    static let cellID = "LWRecentPhotoCell"
    var representedAssetIdentifier: String? = nil
    
    var photo:UIImage!{
        didSet{
            photoPreviewView.image = photo
        }
    }
    var photoPreviewView:UIImageView!
    
    var selectedDotView:UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 8
        //UI设置
        photoPreviewView = UIImageView()
//        photoPreviewView.contentMode = .scaleAspectFill
        photoPreviewView.contentMode = .scaleAspectFit
        photoPreviewView.layer.cornerRadius = 8
        photoPreviewView.clipsToBounds = true
//        photoPreviewView.layer.borderWidth = 1
//        photoPreviewView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.addSubview(photoPreviewView)
        
        selectedDotView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        selectedDotView.alpha = 0
        selectedDotView.contentMode = .scaleAspectFill
        selectedDotView.clipsToBounds = true
        selectedDotView.layer.cornerRadius = 35.0 / 2.0
        self.addSubview(selectedDotView)
  
        
        
    }
    
    func setupConstraints(){
        //约束
        photoPreviewView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectedDotView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 35, height: 35))
            make.right.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func updateSelectedDotView(selected:Bool){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) { [self] in
            if selected{
                selectedDotView.alpha = 1
                self.backgroundColor = .systemGray6
            }else{
                selectedDotView.alpha = 0
                self.backgroundColor = .clear
            }
        } completion: { _ in}
    }
}
