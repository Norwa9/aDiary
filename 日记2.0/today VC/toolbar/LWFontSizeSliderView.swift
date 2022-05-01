//
//  LWFontSizeSliderView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/31.
//

import UIKit

class LWFontSizeSliderView: UIView {
    let contentView:UIView = UIView()
    let slider = UISlider()
    let fontSizeLabel = UILabel()
    var defaultSize:CGFloat!{
        didSet{
            slider.setValue(Float(defaultSize), animated: true)
            fontSizeLabel.text = "\(Int(defaultSize))"
        }
    }
    var toolbar:LWTextViewToolBar
    init(toolbar:LWTextViewToolBar) {
        self.toolbar = toolbar
        super.init(frame: .zero)
        initUI()
        initCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.clipsToBounds = false
        self.layer.cornerRadius = 10
        
        contentView.backgroundColor  = .secondarySystemBackground
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = false
        self.addSubview(contentView)
        
        slider.backgroundColor = .secondarySystemBackground
        slider.minimumValue = 10
        slider.maximumValue = 50
        contentView.addSubview(slider)
        slider.addTarget(self, action: #selector(handleFontSizeChange(picker:)), for: .valueChanged)
        
        
        
        fontSizeLabel.font = UIFont.init(name: "DIN Alternate", size: 20)
        fontSizeLabel.textColor = .label
        contentView.addSubview(fontSizeLabel)
        
        
    }
    
    func initCons(){
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(25)
//            make.top.equalToSuperview().offset(5)
//            make.bottom.equalToSuperview().offset(-5)
        }
        
        fontSizeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(slider.snp.right).offset(5)
            make.centerY.equalTo(slider)
            make.height.equalTo(25)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(30)
        }
    }
    
    @objc func handleFontSizeChange(picker:UISlider){
        let newFontSize = picker.value
        
        fontSizeLabel.text = "\(Int(newFontSize))"
        
        toolbar.handleFontSizeChange(newFontSize: CGFloat(newFontSize))
        
    }
    
    
}
