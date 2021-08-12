//
//  LWTagsView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/30.
//

import UIKit
import TagListView
class LWTagsView: UIView {
    var model:diaryInfo!{
        didSet{
            setModel()
        }
    }
    
    var tagsLabel:TagListView!
    
    init() {
        super.init(frame: .zero)
        initUI()
        setConstriants()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(){
        updateUI()
    }
    
    private func updateUI(){
        tagsLabel.removeAllTags()
        
        for tag in model.tags{
            tagsLabel.addTag("#"+tag)
        }
        
        tagsLabel.addTag("添加+")
    }
    
    private func initUI(){
        //self
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        
        //UI
        tagsLabel = TagListView()
        tagsLabel.textFont = UIFont(name: "DIN Alternate", size: 14)!
        tagsLabel.alignment = .left
        tagsLabel.tagBackgroundColor = .systemGray3
        tagsLabel.textColor = .white
        tagsLabel.cornerRadius = 5
        tagsLabel.clipsToBounds = true
        tagsLabel.isUserInteractionEnabled = false
        
        
        self.addSubview(tagsLabel)
    }
    
    private func setConstriants(){
        tagsLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        }
    }
    
    private func addTapGesture(){
        //gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showTagsViewController))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func showTagsViewController(){
        let vc = tagsViewController(model: model)
        vc.completionHandler = updateUI
        guard let todayVC = UIApplication.getTopViewController() as? todayVC else{
            print("无法获取todayVC")
            return
        }
        todayVC.present(vc, animated: true, completion: nil)
    }
}


