//
//  LWSubpagesView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/21.
//

import UIKit
import JXPagingView
import JXSegmentedView
import StoreKit
import Popover

class LWSubpagesView: UIView {
    var todayVC:todayVC!
    lazy var pagingView: JXPagingView = JXPagingView(delegate: self)
    
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(kSegmentedViewHeight)))
    let kSegmentedViewHeight = 30
    var segmentDataSource = JXSegmentedTitleDataSource()
    var segmentTitles = [String]()
    
    var popover:Popover!
    
    var models:[diaryInfo] = []{
        didSet{
            updateUI(currentIndex: currentPageIndex)
        }
    }
    
    ///初始页面
    var currentPageIndex:Int = 0
    
    ///主页面
    var mainPage:diaryInfo?{
        get{
            if let main = models.first{
                return main
            }
            return nil
        }
    }
    
    var mainTableView:UIScrollView{
        get{
            return pagingView.mainTableView
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        initUI()
        setupPopover()
        setupConstraints()
    }
    
    ///更新UI
    ///currentIndex表示：进入页面后section的初始index
    func updateUI(currentIndex:Int){
        segmentTitles.removeAll()
        for model in models{
//            segmentTitles.append(model.date)
            let pageIndex = model.date.parsePageIndex()
            segmentTitles.append("\(pageIndex + 1)页")
        }
        segmentTitles.append("管理页面")
        segmentDataSource.titles = segmentTitles
        segmentedView.reloadData()
        pagingView.reloadData()
        segmentedView.selectItemAt(index: currentIndex)
    }
    
    private func initUI(){
        //segmentedView
        segmentedView.delegate = self
        segmentDataSource.titleSelectedColor = APP_GREEN_COLOR()
        segmentDataSource.titleNormalFont = userDefaultManager.customFont(withSize: 12)
        segmentDataSource.isTitleZoomEnabled = true
        segmentDataSource.itemSpacing = 10
        segmentDataSource.isItemSpacingAverageEnabled = false
        segmentedView.dataSource = segmentDataSource
        segmentedView.backgroundColor = .systemGray6
        segmentedView.listContainer = pagingView.listContainerView//列表和categoryView联动
        
        pagingView.automaticallyDisplayListVerticalScrollIndicator = false
        self.addSubview(pagingView)
        
    }
    
    private func setupPopover(){
        let options = [
            .type(.auto),
            .cornerRadius(10),
          .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        
        popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
    }
    
    private func setupConstraints(){
        pagingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LWSubpagesView : JXPagingViewDelegate{
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        0
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        print("mainTableView y : \(y)")
        print("mainTableView content height : \(scrollView.contentSize.height)")
        if y < 0{
            scrollView.contentOffset = .zero
        }
        
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        UIView()
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return kSegmentedViewHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return models.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        print("initListAtIndex, index:\(index)")
        let vc = LWTextViewController()
        vc.model = models[index]
        return vc
    }
    
    
}

extension LWSubpagesView : JXSegmentedViewDelegate{
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        guard index == self.models.count , let mainPage = mainPage else{
            return
        }
        let managePagesAlertView = ManagePagesAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
        
        //定义取消操作
        managePagesAlertView.cancelAction = {
            self.popover.dismiss()
        }
        //定义创建页面操作
        managePagesAlertView.createAction = { [self] in
            let newPage = LWRealmManager.shared.createPage(withDate: mainPage.date, pageNumber: models.count)
            models.append(newPage)
            if models.count > 2{
                //请求打分
                if userDefaultManager.requestReviewTimes % 2 == 0{
                    SKStoreReviewController.requestReview()
                    userDefaultManager.requestReviewTimes += 1
                }
            }
            updateUI(currentIndex: models.count - 1)
        }
        
        //定义删除页面操作
        managePagesAlertView.deleteAction = { [self] in
            //主页面不能删
            guard let deleteDiary = models.last,models.count > 1 else{return}
            models.removeLast()
            DiaryStore.shared.delete(with: deleteDiary.id)
            updateUI(currentIndex: 0)
        }
        
        popover.show(managePagesAlertView, fromView: segmentedView)
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        guard index < self.models.count else {return}
        //更新topView
        let model = models[index]
        todayVC.topView.model = model
    }
    
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}
