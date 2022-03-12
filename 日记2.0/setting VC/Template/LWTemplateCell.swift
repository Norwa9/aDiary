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
    private var model:diaryInfo!
    private var delegate:LWTemplateViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// case1：模板管理界面
    public func setViewModel(model:diaryInfo){
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
        self.layer.cornerRadius = 5
        self.addBorder(width: 1, color: .lightGray)
        
        titleLabel = UILabel()
        titleLabel.text = model.date.trimPrefix(prefix: LWTemplateHelper.shared.TemplateNamePrefix)
        titleLabel.font = UIFont(name: "DIN Alternate", size: 14)!
        self.addSubview(titleLabel)
    }
    
    private func setCons(){
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
    }
    
    /// 创建按钮
    private func setupPromptView(){
        self.removeAllSubviews()
        let createButton = UIButton()
        createButton.setImage(UIImage(named: "add"), for: .normal)
        createButton.addTarget(delegate, action: #selector(delegate.createTemplate), for: .touchUpInside)
        self.addSubview(createButton)
        
        createButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(self.snp.height)
        }
    }
}
