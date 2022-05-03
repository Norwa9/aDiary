//
//  LWRecentPhotosPickerView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/2.
//

import Foundation
import UIKit
import Photos

class LWRecentPhotosPickerView:UIView{
    static let kRecentPhotosPickerViewHeight:CGFloat = 300.0
    
    var latestPhotoAssetsFetched: PHFetchResult<PHAsset>? = nil
    var selectedPhotoIndexSet:Set<Int> = []{
        didSet{
            self.updateSelectedCountLabel()
        }
    }
    
    // UI
    var titleLabel:UILabel!
    var presentPhotoPickerBtn:UIButton!
    var collectionView:UICollectionView!
    var cancelButton:UIButton!
    var doneButton:UIButton!
    var selectedPhotoCountLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        setCons()
        
        LWFetchPhotoHelper.shared.fetchLatestPhotos(forCount: 50, callBack: { assets in
            self.latestPhotoAssetsFetched = assets
            if let collectionView =  self.collectionView{
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) {
                    collectionView.reloadData()
                    collectionView.alpha = 1
                } completion: { _ in}
                
            }
        })
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.text = "选取图片"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        selectedPhotoCountLabel = UILabel()
        selectedPhotoCountLabel.layer.masksToBounds = true
        selectedPhotoCountLabel.layer.cornerRadius = 15.0
        selectedPhotoCountLabel.textAlignment = .center
        selectedPhotoCountLabel.text = "0"
        selectedPhotoCountLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        selectedPhotoCountLabel.backgroundColor = .systemGray6
        
        
        presentPhotoPickerBtn = UIButton()
        presentPhotoPickerBtn.addTarget(self, action: #selector(presentPicker(_:)), for: .touchUpInside)
        presentPhotoPickerBtn.setAttributedTitle(NSAttributedString(string: "从相册选取").addingAttributes(
            [.foregroundColor : UIColor.label,
             .font : UIFont.systemFont(ofSize: 16, weight: .bold),
             ]), for: .normal)
        presentPhotoPickerBtn.backgroundColor = .systemGray6
        presentPhotoPickerBtn.layer.cornerRadius = 10
        presentPhotoPickerBtn.setImage(UIImage(systemName: "person.2.crop.square.stack"), for: .normal)
        presentPhotoPickerBtn.tintColor = .label
        presentPhotoPickerBtn.contentHorizontalAlignment = .center
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LWRecentPhotoCell.cellW, height: LWRecentPhotoCell.cellH)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LWRecentPhotoCell.self, forCellWithReuseIdentifier: LWRecentPhotoCell.cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
        
        cancelButton = UIButton()
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setAttributedTitle(NSAttributedString(string: "取消").addingAttributes(
            [.foregroundColor : UIColor.secondaryLabel,
             .font : UIFont.systemFont(ofSize: 16, weight: .bold)]), for: .normal)
        
        doneButton = UIButton()
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.setAttributedTitle(NSAttributedString(string: "插入").addingAttributes(
            [.foregroundColor : UIColor.white,
             .font : UIFont.systemFont(ofSize: 16, weight: .bold)]), for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 10
        
        self.addSubview(titleLabel)
        self.addSubview(selectedPhotoCountLabel)
        self.addSubview(presentPhotoPickerBtn)
        self.addSubview(collectionView)
        self.addSubview(cancelButton)
        self.addSubview(doneButton)
    }
    
    private func setCons(){
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(8)
        }
        
        self.selectedPhotoCountLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerX.equalTo(self.doneButton)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-20)
        }
        self.cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(doneButton)
            make.right.equalTo(doneButton.snp.left).offset(-10)
        }
        
        self.presentPhotoPickerBtn.snp.makeConstraints { make in
            make.centerY.equalTo(doneButton)
            make.left.equalToSuperview().offset(18)
            make.size.equalTo(CGSize(width: 120, height: 30))
        }
    }
    
    @objc func presentPicker(_ sender:UIButton){
        sender.showBounceAnimation {
            UIApplication.getTextVC()?.showPhotoPicker()
            self.cancel()
        }
        
    }
    
    @objc func cancel(){
        UIApplication.getTextVC()?.toggleRecentPhotoPickerView()
    }
    
    @objc func done(){
        if selectedPhotoIndexSet.isEmpty{
            return
        }
        
        var selectedPhotos:[UIImage] = []
        for index in selectedPhotoIndexSet{
            guard let asset = self.latestPhotoAssetsFetched?[index] else {
                continue
            }
            let requestOption = PHImageRequestOptions()
            requestOption.deliveryMode = .highQualityFormat
            requestOption.resizeMode = .exact
            requestOption.isSynchronous = true // 同步执行
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOption) { imageData, _, _, _ in
                if let imageData = imageData, let photo = UIImage(data: imageData){
                    print(photo.size)
                    selectedPhotos.append(photo)
                }
            }
        }
        UIApplication.getTextVC()?.insertPhotos(images: selectedPhotos)
        
        self.selectedPhotoIndexSet.removeAll()
        self.collectionView.reloadData()
    }
    
    private func updateSelectedCountLabel(){
        self.selectedPhotoCountLabel.showBounceAnimation {}
        self.selectedPhotoCountLabel.text = "\(self.selectedPhotoIndexSet.count)"
    }
}

extension LWRecentPhotosPickerView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.latestPhotoAssetsFetched?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LWRecentPhotoCell.cellID, for: indexPath) as! LWRecentPhotoCell
        
        let index = indexPath.item
        
        
        // 1. 设置选取状态
        let seleced = selectedPhotoIndexSet.contains(index)
        cell.updateSelectedDotView(selected: seleced)
        
        // 2. 设置图片
        guard let asset = self.latestPhotoAssetsFetched?[index] else {
            return cell
        }
        cell.representedAssetIdentifier = asset.localIdentifier
        let ratio:CGFloat = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
        let imageSize = CGSize(
            width: globalConstantsManager.shared.kScreenWidth,
            height: globalConstantsManager.shared.kScreenWidth * ratio)
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil) { photo, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier{
                cell.photo = photo
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LWRecentPhotoCell else{
            return
        }
        LWImpactFeedbackGenerator.impactOccurred(style: .light)
        cell.showBounceAnimation {}
        
        let index = indexPath.item
        let hasSelected = self.selectedPhotoIndexSet.contains(index)
        cell.updateSelectedDotView(selected: !hasSelected)
        if !hasSelected{
            self.selectedPhotoIndexSet.insert(index)
        }else{
            self.selectedPhotoIndexSet.remove(index)
        }
        print("当前选择：\(selectedPhotoIndexSet)")
    }
    
    
    
}
