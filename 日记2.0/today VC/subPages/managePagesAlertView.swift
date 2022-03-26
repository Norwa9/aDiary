//
//  managePagesAlertView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/22.
//

import Foundation
import UIKit


class ManagePagesAlertView: UIView {
    let title = UILabel()
    let cancelButton = UIButton()
    let createDiaryButton = UIButton()
    
    var showCreateOptVC:(() -> ()) = {}
    var deleteAction:(() -> ()) = {}
    var cancelAction:(() -> ()) = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPopover), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        self.backgroundColor = .white // 无法适配夜间模式.systemBackground
        
        //标题
        title.frame = CGRect(x: 0, y: 12, width: 150, height: 24)
        title.textAlignment = .center
        title.font = UIFont.init(name: "DIN Alternate", size: 20)
        title.text = "管理页面"
        title.textColor = .black
        self.addSubview(title)
        
        //创建按钮
        createDiaryButton.frame = CGRect(x: 104, y: 44, width: 30, height: 30)
        let createDiaryButtonAttributes:[NSAttributedString.Key:Any] = [
            .font:UIFont.init(name: "DIN Alternate", size: 15)!,
            .foregroundColor:APP_GREEN_COLOR()
        ]
        let attr1 = NSAttributedString(string: "添加", attributes: createDiaryButtonAttributes)
        createDiaryButton.setAttributedTitle(attr1, for: .normal)
        createDiaryButton.addTarget(self, action: #selector(createSubpage), for: .touchUpInside)
        self.addSubview(createDiaryButton)
        
        //取消按钮
        cancelButton.frame = CGRect(x: 16, y: 44, width: 30, height: 30)
        let cancelButtonAttributes:[NSAttributedString.Key:Any] = [
            .font:UIFont.init(name: "DIN Alternate", size: 15)!,
            .foregroundColor : UIColor.red,
        ]
        let attr2 = NSAttributedString(string: "删除", attributes: cancelButtonAttributes)
        cancelButton.setAttributedTitle(attr2, for: .normal)
        cancelButton.addTarget(self, action: #selector(deleteSubpage), for: .touchUpInside)
        self.addSubview(cancelButton)
        
        
    }
    
    
    @objc func createSubpage() {
        self.showCreateOptVC()
        self.dismissPopover()
    }
    
    @objc func deleteSubpage() {
        let ac = UIAlertController(title: "❗️删除当前页", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            self.dismissPopover()
        }))
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            self.deleteAction()
            self.dismissPopover()
        }))
        let todayVC = UIApplication.getTodayVC()
        todayVC?.present(ac, animated: true, completion: nil)
    }
    
    @objc func dismissPopover(){
        cancelAction()
    }
    
    
}
