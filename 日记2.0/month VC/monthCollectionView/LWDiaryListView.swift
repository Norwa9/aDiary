//
//  diaryListCollectionView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation
import UIKit
import MJRefresh


class LWDiaryListView : UIView{
    var viewModel:monthViewModel
    let monthVC = UIApplication.getMonthVC()
    
    var dataSource:[diaryInfo]
    var collectionView:UICollectionView!
    var flowLayout:waterFallLayout!///瀑布流布局
    var footer:MJRefreshAutoNormalFooter!
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        self.dataSource = viewModel.dataSource
        super.init(frame: .zero)
        
        
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    private func initUI(){
        flowLayout = waterFallLayout()
        flowLayout.columnNumber = layoutParasManager.shared.collectioncolumnNumber
        flowLayout.interitemSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.lineSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.dataSource = dataSource
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = LWColorConstatnsManager.LWSoftBGColor
        collectionView.contentInset = layoutParasManager.shared.collectionEdgesInset
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(monthCell.self, forCellWithReuseIdentifier: monthCell.reusableID)
        collectionView.showsVerticalScrollIndicator = false
        
        self.addSubview(collectionView)
    }
    
    private func setCons(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 进入/退出搜索模式时，给 collectionView 配置/移除 MJRefresh
    private func setupMJRefresh(){
        if viewModel.isFilterMode{
            footer = MJRefreshAutoNormalFooter()
            footer.setRefreshingTarget(self, refreshingAction: #selector(loadMoreDiray))
            self.collectionView.mj_footer = footer
        }else{
            footer.removeFromSuperview()
        }
    }
    
    
    // MARK: Public
//    func configureDataSource(year:Int,month:Int){
//        //print("configureDataSource")
//        let dataSource = diariesForMonth(forYear: year, forMonth: month)
//        filteredDiaries.removeAll()
//        filteredDiaries = dataSource
//        flowLayout.dataSource = filteredDiaries
//        reloadCollectionViewData()
//    }
    /// 更新数据源
    public func updateDataSource(forRow row:Int = -1,animated:Bool = false, duration:TimeInterval = 1.0){
        self.dataSource.removeAll()
        self.dataSource = viewModel.dataSource
        self.flowLayout.dataSource = viewModel.dataSource
        
        // 更新UI
        // 更新数据源，然后就得更新UI
        self.reloadCollectionViewData(forRow:row,animated: animated, animationDuration: duration)
    }
    
    
    /// 更新UI
    /// 更新UI可以单独调用，因为切换瀑布流布局时，DataSource 没有改变，也就就没有调用 updateDataSource
    public func reloadCollectionViewData(forRow:Int = -1,animated:Bool = false,animationDuration:TimeInterval = 1.0){
        if forRow == -1{
            if !animated{
                self.collectionView.reloadData()
                self.layoutIfNeeded()
                return
            }
            
            //暂时关闭按钮，防止切换月份导致多次performBatchUpdates
            self.viewModel.performingLayoutSwitch = true
            
            ///更新瀑布流布局
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction]) {
                self.collectionView.performBatchUpdates({
                    //让cell以平滑动画移动到新位置上去
                    self.collectionView.reloadData()
                    
                    //让cell以平滑动画更新size
                    for cell in self.collectionView.visibleCells{
                        let cell = cell as! monthCell
                        cell.updateCons()
                    }
                }, completion: nil)
            } completion: { (_) in
                self.viewModel.performingLayoutSwitch = false
            }
            
            self.layoutIfNeeded()//预加载cell，避免第一次进入collectionview加载带来的卡顿
        }else{
            if viewModel.isFilterMode{
                self.collectionView.reloadData()
            }else{
                self.collectionView.reloadItems(at: [IndexPath(row: forRow, section: 0)])
            }
        }
    }
    
    
    /// 切换搜索模式时，更新list view
    /// 包括更新MJRefresh、更新数据源
    public func updateUIForFilterMode(){
        // 1. 设置刷新器
        setupMJRefresh()
        
        // 2. 清空/恢复数据源
        if viewModel.isFilterMode{
            self.dataSource.removeAll()
            self.reloadCollectionViewData()
        }else{
            viewModel.loadDataSource(year: viewModel.selectedYear, month: viewModel.selectedMonth)
            self.updateDataSource()
        }
        
    }
    
    /// 选择的月份变更时刷新数据源
    public func updateUIForDateChange(){
        self.updateDataSource()
    }
}

// MARK: Delegate
extension LWDiaryListView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("cellForItemAt monthCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCell.reusableID, for: indexPath) as! monthCell
        let row = indexPath.row
        let diary = dataSource[row]
        cell.setViewModel(diary)
        cell.cellRow = row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedDiary = dataSource[row]
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        
        //点击动画
        LWImpactFeedbackGenerator.impactOccurred(style: .light)
        cell.showBounceAnimation {}
        cell.showSelectionPrompt()
        UIApplication.getMonthVC()?.presentEditorVC(withViewModel: selectedDiary)
    }

    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging || viewModel.isFilterMode || collectionView.contentOffset.y > globalConstantsManager.shared.kScreenHeight{
            return
        }else{
            guard let cell = cell as? monthCell else{return}
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: -50)
            UIView.animate(withDuration: 0.7, delay: 0.1 * Double(indexPath.row), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut]) {
                cell.alpha = 1
                cell.transform = .identity
            } completion: { (_) in
                
            }
        }
    }
}

//MARK:  -context Menu
extension LWDiaryListView {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            //
            let shareDiaryAction = UIAction(title: NSLocalizedString("保存日记为图片", comment: ""),
                                         image: UIImage(named: "share")) { action in
                                    self.performDiaryShare(indexPath)
                                }
            let shareSummaryAction = UIAction(title: NSLocalizedString("保存摘要为图片", comment: ""),
                                         image: UIImage(named: "share")) { action in
                                    self.performSummaryShare(indexPath)
                                }
            
            //
            let deleteAction = UIAction(title: NSLocalizedString("删除", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                        self.performDelete(indexPath)
                        }
            return UIMenu(title: "", children: [shareDiaryAction, shareSummaryAction,deleteAction])
        }
        
        
        return config
    }
    
    func performDiaryShare(_ indexPath:IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        let share = shareVC(monthCell: cell)
        UIApplication.getMonthVC()?.present(share, animated: true, completion: nil)
    }
    
    func performSummaryShare(_ indexPath:IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        let summaryImage = cell.asImage(inset: -5) // -5是为了截到cell周围的阴影
        LWImageSaver.shared.saveImage(image: summaryImage)
    }
    
    
    func performDelete(_ indexPath:IndexPath){
        let ac = UIAlertController(title: "是否删除此篇日记？", message: "该日期下所有日记都会被删除", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [self] _ in
            let row = indexPath.item
            let cellModel = dataSource[row]
            DiaryStore.shared.deleteAllPage(withPageID: cellModel.id)
        }))
        monthVC?.present(ac, animated: true, completion: nil)
    }
}

//MARK: -MJRefresh
extension LWDiaryListView{
    @objc func loadMoreDiray(){
        // print("loadMoreDiray")
        var currentNum = self.dataSource.count
        if currentNum < viewModel.filteredDiaries.count{
            currentNum += 10
            let dataNum = min(currentNum, viewModel.filteredDiaries.count)
            self.dataSource = Array(viewModel.filteredDiaries.prefix(dataNum))
            self.flowLayout.dataSource = self.dataSource
            footer.setTitle("点击或上拉加载更多(\(self.dataSource.count)/\(viewModel.filteredDiaries.count))", for: .refreshing)
        }else{
            //读取完毕
            footer.setTitle("读取完毕", for: .idle)
            self.collectionView.mj_footer?.endRefreshing {}
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadCollectionViewData()
            self.collectionView.mj_footer?.endRefreshing {}
        }
        
    }
}
