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
    
    var createAction:(() -> ()) = {}
    var deleteAction:(() -> ()) = {}
    var cancelAction:(() -> ()) = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancel), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        self.backgroundColor = .systemBackground
        
        //标题
        title.frame = CGRect(x: 0, y: 12, width: 150, height: 24)
        title.textAlignment = .center
        title.font = UIFont.init(name: "DIN Alternate", size: 20)
        title.text = "管理页面"
        title.textColor = .label
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
        let ac = UIAlertController(title: "添加新的一页", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            self.cancelAction()
        }))
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            self.createAction()
            self.cancel()
        }))
        let todayVC = UIApplication.getTodayVC()
        todayVC?.present(ac, animated: true, completion: nil)
    }
    
    @objc func deleteSubpage() {
        let ac = UIAlertController(title: "将会删除最后一页", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            self.cancelAction()
        }))
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            self.deleteAction()
            self.cancel()
        }))
        let todayVC = UIApplication.getTodayVC()
        todayVC?.present(ac, animated: true, completion: nil)
    }
    
    @objc func cancel(){
        cancelAction()
    }
    
    
}
