//
//  LWToolBarButton.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/30.
//

import UIKit

class LWToolBarButton: UIButton {
    var image:UIImage?
    var buttonImageView:UIImageView!
    var isOn: Bool = false{
        didSet{
            toggleSelectedView()
        }
    }
    
    init(image:UIImage?) {
        self.image = image
        super.init(frame: .zero)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 10
        self.backgroundColor = .tertiarySystemBackground
        self.setupShadow(opacity: 0.35, radius: 1, offset:.zero, color: .black)
        
        buttonImageView = UIImageView(image: image)
        buttonImageView.contentMode = .scaleAspectFit
        self.addSubview(buttonImageView)
    }
    
    func initCons(){
        buttonImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        }
    }
    
    func toggleSelectedView(){
        if isOn{
            UIView.animate(withDuration: 0.2) {
                self.transform = .init(scaleX: 0.8, y: 0.8)
            }
        }else{
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
    
    
}
