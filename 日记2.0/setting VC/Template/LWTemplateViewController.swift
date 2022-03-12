//
//  LWTemplateViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

class LWTemplateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var titleLabel:UILabel!
    private var collectionView:UICollectionView!
    private var templateCollectionViewLayout = UICollectionViewFlowLayout()
    private var templates:[diaryInfo] = []
    private var editorVC:todayVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        initUI()
        setCons()
    }
    
    private func loadData(){
        templates = LWTemplateHelper.shared.getTemplateFor(templateName: nil)
        
        editorVC = todayVC()
        let _ = editorVC.view
        editorVC.modalPresentationStyle = .custom
        editorVC.transitioningDelegate = self
    }
    
    private func reloadData(){
        templates = LWTemplateHelper.shared.getTemplateFor(templateName: nil)
        self.collectionView.reloadData()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.text = "模板"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        templateCollectionViewLayout.itemSize = CGSize(
            width: globalConstantsManager.shared.kScreenWidth - 20,
            height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: templateCollectionViewLayout)
        collectionView.register(LWTemplateCell.self, forCellWithReuseIdentifier: LWTemplateCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(collectionView)
    }
    
    private func setCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LWTemplateCell.reuseID, for: indexPath) as! LWTemplateCell
        let row = indexPath.item
        if row == templates.count{
            cell.setPromptView(delegate: self)
        }else{
            cell.setViewModel(model:templates[row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if row == templates.count{
            return
        }else{
            let template = templates[row]
            self.editorVC.model = template
            self.present(self.editorVC, animated: true, completion: nil)
        }
    }
    
    @objc func createTemplate(){
        let ac = UIAlertController(title: "请输入模板名称：", message: "", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            
        }))
        ac.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
            // 检查是否已存在
            guard let textField = ac.textFields?[0], let templateName = textField.text else {return}
            if let _ = LWTemplateHelper.shared.getTemplateFor(templateName: templateName).first{
                ac.view.shake()
                return
            }else{
                let template = LWTemplateHelper.shared.createTemplate(name: templateName)
                self.editorVC.model = template
                self.present(self.editorVC, animated: true, completion: nil)
                self.reloadData()
            }
        }))
        self.present(ac, animated: true, completion: nil)
        
    }
    
    
}

extension LWTemplateViewController:UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = editorAnimator()
        animator.animationType = .present
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = editorAnimator()
        animator.animationType = .dismiss
        return animator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return editorBlurPresentVC(presentedViewController: presented, presenting: presenting)
    }
}
