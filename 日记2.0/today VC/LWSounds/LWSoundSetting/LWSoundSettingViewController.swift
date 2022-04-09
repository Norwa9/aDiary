//
//  LWSoundSettingViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/21.
//

import Foundation
import UIKit

class LWSoundSettingViewController:UIViewController{
    var containerView:UIView!
    var titleLabel:UILabel!
    
    var renameBtn:LWButton!
    var shareBtn:LWButton!
    var deleteBtn:LWButton!
    
    var viewModel:LWSoundViewModel
    
    let btnW:CGFloat = 70.0
    let btnH:CGFloat = 100.0
    
    
    init(viewModel:LWSoundViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.backgroundColor =  .systemBackground
        containerView.layer.cornerRadius = 10
        
        titleLabel = UILabel()
        titleLabel.text = "更多操作"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        renameBtn = LWButton(imageName: nil, imageSystemName: "pencil.circle", title: "重命名")
        renameBtn.imageView.tintColor = .label
        renameBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rename)))
        
        shareBtn = LWButton(imageName: nil, imageSystemName: "square.and.arrow.up", title: "分享")
        shareBtn.imageView.tintColor = .label
        shareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        
        deleteBtn = LWButton(imageName: nil, imageSystemName: "trash", title: "删除")
        deleteBtn.imageView.tintColor = .red
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteSoundView)))
        
       
        
        self.view.addSubview(containerView)
        self.containerView.addSubview(titleLabel)
        self.containerView.addSubview(renameBtn)
        self.containerView.addSubview(shareBtn)
        self.containerView.addSubview(deleteBtn)
        
    }
    
    private func setCons(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
        }
        
        renameBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: btnW, height: btnH))
            make.centerX.equalTo(containerView.snp.centerX).offset(-(btnW + 10))
            make.centerY.equalToSuperview().offset(15)
        }
        
        shareBtn.snp.makeConstraints { make in
            make.centerY.equalTo(renameBtn)
            make.size.equalTo(renameBtn)
            make.centerX.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.centerY.equalTo(renameBtn)
            make.size.equalTo(renameBtn)
            make.centerX.equalTo(containerView.snp.centerX).offset(btnW + 10)
        }
    }
    
    @objc func rename(){
        viewModel.renameSoundFile()
    }
    
    @objc func share(){
        viewModel.shareSoundFile()
    }
    
    @objc func deleteSoundView(){
        let ac = UIAlertController(title: "是否删除该录音？", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            self.delete()
        }))
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
    
    func delete(){
        self.dismiss(animated: true) {
            self.viewModel.deleteSoundView()
        }
    }
}
// MARK: UIViewControllerTransitioningDelegate
extension LWSoundSettingViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting,viewHeight: 200)
    }
}
