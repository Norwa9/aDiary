//
//  LWButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/21.
//

import Foundation
import UIKit

class LWButton:UIView{
    private var imageName:String?
    private var imageSystemName:String?
    private var title:String
    
    var imageContainer:UIView!
    var imageView:UIImageView!
    private var titleLabel:UILabel!
    
    init(imageName:String?,imageSystemName:String?,title:String) {
        self.imageName = imageName
        self.imageSystemName = imageSystemName
        self.title = title
        super.init(frame: .zero)
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        imageContainer = UIView()
        imageContainer.layer.cornerRadius = 8
        imageContainer.backgroundColor = .secondarySystemBackground
        
        if let imageName = imageName {
            imageView = UIImageView(image: UIImage(named: imageName))
        }else{
            if let imageSystemName = imageSystemName {
                imageView = UIImageView(image: UIImage(systemName: imageSystemName))
            }
        }
        imageView.contentMode = .scaleAspectFit
        
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        
        self.addSubview(imageContainer)
        self.imageContainer.addSubview(imageView)
        self.addSubview(titleLabel)
    }
    
    func setCons(){
        imageContainer.snp.makeConstraints { make in
            make.width.height.equalTo(self.snp.width)
            make.top.left.right.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
}
    
