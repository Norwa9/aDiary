//
//  LWTemplateViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/12.
//

import UIKit

class LWTemplateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        editorVC.modalPresentationStyle = .fullScreen
    }
    
    private func initUI(){
        templateCollectionViewLayout.itemSize = CGSize(
            width: globalConstantsManager.shared.kScreenWidth - 20,
            height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: templateCollectionViewLayout)
        collectionView.register(LWTemplateCell.self, forCellWithReuseIdentifier: LWTemplateCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
    }
    
    private func setCons(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LWTemplateCell.reuseID, for: indexPath) as! LWTemplateCell
        let row = indexPath.item
        cell.setViewModel()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let template = templates[indexPath.row]
        let name = "测试"
        if let template = LWTemplateHelper.shared.getTemplateFor(templateName: name).first{
            editorVC.model = template
            self.present(editorVC, animated: true, completion: nil)
            return
        }else{
            let template = LWTemplateHelper.shared.createTemplate(name: name)
            editorVC.model = template
            self.present(editorVC, animated: true, completion: nil)
        }
    }
    
}
