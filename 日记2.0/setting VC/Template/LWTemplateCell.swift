//
//  LWTemplateCell.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

class LWTemplateCell: UICollectionViewCell {
    static let reuseID = "LWTemplateCell"
    private var titleLabel:UILabel!
    
    private var delegate:LWTemplateViewController!
    private var model:diaryInfo!
    private var editable:Bool = false
    private var editImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// case1：模板管理界面
    public func setViewModel(model:diaryInfo,editable:Bool = false){
        self.editable = editable
        self.model = model
        self.initUI()
        self.setCons()
    }
    
    /// case2：模板创建
    public func setPromptView(delegate:LWTemplateViewController){
        self.delegate = delegate
        self.setupPromptView()
    }
    
    private func initUI(){
        self.removeAllSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.addBorder(width: 1, color: .lightGray)
        
        titleLabel = UILabel()
        titleLabel.text = model.date.trimPrefix(prefix: LWTemplateHelper.shared.TemplateNamePrefix)
        titleLabel.font = UIFont(name: "DIN Alternate", size: 14)!
        
//        let image = UIImage(named: "chevron.forward.circle")
        let image = UIImage(systemName: "chevron.forward")
        editImageView = UIImageView(image: image)
        editImageView.tintColor = .lightGray
        editImageView.alpha = editable ? 1 : 0
        
        self.addSubview(editImageView)
        self.addSubview(titleLabel)
    }
    
    private func setCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        editImageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(editImageView.snp.height).multipliedBy(0.6)
        }
    }
    
    /// 创建按钮
    private func setupPromptView(){
        self.removeAllSubviews()
        self.addBorder(width: 0, color: .lightGray)
        
        let createButton = UIButton()
        createButton.setImage(UIImage(named: "add"), for: .normal)
        createButton.addTarget(delegate, action: #selector(delegate.createTemplate), for: .touchUpInside)
        self.addSubview(createButton)
        
        createButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(self.snp.height).multipliedBy(0.8)
        }
    }
}
