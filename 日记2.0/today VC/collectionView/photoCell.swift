//
//  photoCell.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/31.
//

import UIKit

class photoCell: UICollectionViewCell {
    static let reusableId = "photoCell"
    
    @IBOutlet weak var photoImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI(){
        self.layer.masksToBounds = false//masksToBounds表示切除边界以外的部分，然而阴影就在边界之外
        self.backgroundColor = .white
        self.setupShadow(opacity: 1, radius: 5, offset: .zero, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        self.layer.cornerRadius = 10
        photoImageView.layer.cornerRadius = 10
        
    }

}
