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
    static let cellW:CGFloat = 114.0 // (187 - 35 ) / 4 * 3 = 114.0
    static let cellH:CGFloat = 187.0
    static let selectedDotW:CGFloat = 35
    var representedAssetIdentifier: String? = nil
    
    var photo:UIImage!{
        didSet{
            photoPreviewView.image = photo
        }
    }
    var photoPreviewView:UIImageView!
    
    var selectedDotBGView:UIView!
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
        
        
        selectedDotBGView = UIView()
        selectedDotBGView.backgroundColor = .clear
        selectedDotBGView.layer.cornerRadius = 8
        photoPreviewView.clipsToBounds = true
        self.addSubview(selectedDotBGView)
        
        selectedDotView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        selectedDotView.tintColor = .black
        selectedDotView.alpha = 0
        selectedDotView.contentMode = .scaleAspectFill
        selectedDotView.clipsToBounds = true
        selectedDotView.layer.cornerRadius = LWRecentPhotoCell.selectedDotW / 2.0
        self.addSubview(selectedDotView)
  
        
        
    }
    
    func setupConstraints(){
        //约束
        photoPreviewView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        selectedDotBGView.snp.makeConstraints { make in
            make.top.equalTo(photoPreviewView.snp.bottom)
            make.height.equalTo(selectedDotView)
            make.left.right.bottom.equalToSuperview()
        }
        
        selectedDotView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: LWRecentPhotoCell.selectedDotW, height: LWRecentPhotoCell.selectedDotW))
            make.bottom.equalToSuperview()
        }
    }
    
    func updateSelectedDotView(selected:Bool){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) { [self] in
            if selected{
                selectedDotView.alpha = 1
                self.selectedDotBGView.backgroundColor = .systemGray6
            }else{
                selectedDotView.alpha = 0
                self.selectedDotBGView.backgroundColor = .clear
            }
        } completion: { _ in}
    }
}
