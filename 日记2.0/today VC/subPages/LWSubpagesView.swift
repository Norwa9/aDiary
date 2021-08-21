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

class LWSubpagesView: UIView {
    var todayVC:todayVC!
    lazy var pagingView: JXPagingView = JXPagingView(delegate: self)
    
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(50)))
    var segmentDataSource = JXSegmentedTitleDataSource()
    var segmentTitles = [String]()
    
    var models:[diaryInfo] = []{
        didSet{
            updateUI()
        }
    }
    
    var mainPage:diaryInfo?{
        get{
            if let main = models.first{
                return main
            }
            return nil
        }
    }
    
    ///获得当前的textView
    var textView:LWTextView{
        print("get listContainerView.scrollView")
        return pagingView.listContainerView.scrollView as! LWTextView
    }
    
    init() {
        super.init(frame: .zero)
        
        initUI()
        setupConstraints()
    }
    
    func updateUI(){
        segmentTitles.removeAll()
        for model in models{
//            segmentTitles.append(model.date)
            let pageIndex = model.date.parsePageIndex()
            segmentTitles.append("page.\(pageIndex + 1)")
        }
        segmentTitles.append("新建")
        segmentDataSource.titles = segmentTitles
        segmentedView.reloadData()
        pagingView.reloadData()
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
        segmentedView.listContainer = pagingView.listContainerView//列表和categoryView联动
        
        
        pagingView.automaticallyDisplayListVerticalScrollIndicator = false
        self.addSubview(pagingView)
        
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
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        UIView()
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return 30
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
        
        let newPage = LWRealmManager.shared.createPage(withDate: mainPage.date, pageNumber: models.count)
        models.append(newPage)
        if models.count > 2{
            SKStoreReviewController.requestReview()
        }
        updateUI()
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        guard index < self.models.count else {return}
        let model = models[index]
        todayVC.topView.model = model//更新topView
    }
    
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}
