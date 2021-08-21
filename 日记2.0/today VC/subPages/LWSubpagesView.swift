//
//  LWSubpagesView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/21.
//

import UIKit
import JXPagingView
import JXSegmentedView

class LWSubpagesView: UIView {
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
            let pageIndex = model.date.parsePageIndex()
            segmentTitles.append("第\(pageIndex)篇")
        }
        segmentTitles.append("+")
        segmentDataSource.titles = segmentTitles
        segmentedView.reloadData()
        pagingView.reloadData()
    }
    
    private func initUI(){
        //segmentedView
        segmentedView.delegate = self
        segmentDataSource.titleSelectedColor = APP_GREEN_COLOR()
        segmentDataSource.titleNormalFont = userDefaultManager.customFont(withSize: 14)
        segmentDataSource.isTitleZoomEnabled = true
        segmentedView.dataSource = segmentDataSource
        
        
        
        
        //列表和categoryView联动
        segmentedView.listContainer = pagingView.listContainerView
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
        return 50
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
        self.models.append(newPage)
        self.updateUI()
    }
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}
