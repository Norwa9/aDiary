//
//  LWPlayButton.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/20.
//

import Foundation
import UIKit

class LWPlayButton:UIView{
    private var imageView:UIImageView!
    
    
    init() {
        super.init(frame: .zero)
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        imageView = UIImageView(image: UIImage(named: "play"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        
        self.addSubview(imageView)
    }
    
    func setCons(){
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func togglePlayState(isPlaying:Bool){
        if isPlaying{
            imageView.image = UIImage(named: "stop")
        }else{
            imageView.image = UIImage(named: "play")
        }
    }
}
