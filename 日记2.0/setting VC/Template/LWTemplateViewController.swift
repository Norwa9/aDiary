//
//  LWTemplateViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

class LWTemplateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var titleLabel:UILabel!
    private var promptLabel:UILabel!
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
        templates = LWTemplateHelper.shared.getTemplateFor(templateRawName: nil)
        
        editorVC = todayVC()
        let _ = editorVC.view
        editorVC.subpagesView.kSegmentedViewHeight = 0 // 在模板模式下隐藏页号
        editorVC.modalPresentationStyle = .custom
        editorVC.transitioningDelegate = self
    }
    
    private func reloadData(){
        templates = LWTemplateHelper.shared.getTemplateFor(templateRawName: nil)
        self.collectionView.reloadData()
        
        // 更新LWCreateOptionViewController中的模板列表
        if let presentedVC = self.presentingViewController as? LWCreateOptionViewController{
            presentedVC.reloadData()
        }
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.text = "模板"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        promptLabel = UILabel()
        promptLabel.text = "长按编辑"
        promptLabel.textColor = .secondaryLabel
        promptLabel.font = .systemFont(ofSize: 12)
        
        templateCollectionViewLayout.itemSize = CGSize(
            width: globalConstantsManager.shared.kScreenWidth - 20,
            height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: templateCollectionViewLayout)
        collectionView.register(LWTemplateCell.self, forCellWithReuseIdentifier: LWTemplateCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(promptLabel)
        self.view.addSubview(titleLabel)
        self.view.addSubview(collectionView)
    }
    
    private func setCons(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        promptLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-10)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == templates.count{
            return nil
        }
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            //
            let renameAction = UIAction(title: NSLocalizedString("模板重命名", comment: ""),
                                         image: UIImage(systemName: "pencil.slash")) { action in
                                    self.performRename(indexPath)
                                }
            
            //
            let deleteAction = UIAction(title: NSLocalizedString("删除模板", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                        self.performDelete(indexPath)
                        }
            
            return UIMenu(title: "", children: [renameAction,deleteAction])
        }
        
        
        return config
    }
    
    func performRename(_ indexPath:IndexPath){
        let ac = UIAlertController(title: "重命名该模板", message: "请输入新的名称", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            //
        }))
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            if let text = ac.textFields?[0].text{
                let template = self.templates[indexPath.row]
                LWTemplateHelper.shared.modifyTempalteName(oldTemplateRawName: template.date.trimPrefix(prefix: LWTemplateHelper.shared.TemplateNamePrefix), newTemplateRawName: text)
                self.reloadData()
            }
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    func performDelete(_ indexPath:IndexPath){
        let ac = UIAlertController(title: "删除该模板", message: "注意：删除后不可恢复", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            //
        }))
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            let template = self.templates[indexPath.row]
            LWTemplateHelper.shared.deleteTemplate(templateRawName: template.date.trimPrefix(prefix: LWTemplateHelper.shared.TemplateNamePrefix))
            self.reloadData()
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    // MARK: 创建模板/付费提示
    @objc func createTemplate(){
        if templates.count >= 3 && !(userDefaultManager.purchaseEdition == .purchased){
            let ac = UIAlertController(title: "✨创建更多模板✨", message: "请解锁完整版", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            }))
            ac.addAction(UIAlertAction(title: "🔓解锁", style: .default, handler: { (_) in
                let iapVC = IAPViewController()
                self.present(iapVC, animated: true, completion: nil)
            }))
            self.present(ac, animated: true, completion: nil)
        }
        else{
            let ac = UIAlertController(title: "请输入模板名称：", message: "", preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            ac.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
                // 检查是否已存在
                guard let textField = ac.textFields?[0], let templateName = textField.text else {return}
                if let _ = LWTemplateHelper.shared.getTemplateFor(templateRawName: templateName).first{
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
