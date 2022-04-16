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
    
    init(image:UIImage?,inset:UIEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)) {
        self.image = image
        super.init(frame: .zero)
        initUI()
        initCons(imageInset: inset)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 10
        self.backgroundColor = .tertiarySystemBackground
        self.setupShadow(opacity: 0.3, radius: 1, offset: .zero, color: LWColorConstatnsManager.LWShodowColor)
        
        buttonImageView = UIImageView(image: image)
        buttonImageView.contentMode = .scaleAspectFit
        self.addSubview(buttonImageView)
    }
    
    func initCons(imageInset inset: UIEdgeInsets){
        buttonImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(inset)
        }
    }
    
    func toggleSelectedView(){
        if isOn{
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                self.transform = .init(scaleX: 0.85, y: 0.85)
            } completion: { (_) in
                
            }
        }else{
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                self.transform = .identity
            } completion: { (_) in
                
            }
        }
    }
    
    
}
