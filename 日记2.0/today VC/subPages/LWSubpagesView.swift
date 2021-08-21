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
    
    var models:[diaryInfo] = []
    
    ///获得当前的textView
    var textView:LWTextView{
        return pagingView.listContainerView.scrollView as! LWTextView
    }
    
    init() {
        super.init(frame: .zero)
        
        initUI()
        setupConstraints()
    }
    
    private func initUI(){
        //segmentedView
        segmentDataSource.titles = segmentTitles
        segmentedView.delegate = self
        segmentedView.dataSource = segmentDataSource
        
        self.addSubview(pagingView)
        //列表和categoryView联动
        segmentedView.listContainer = pagingView.listContainerView
        
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
        return segmentTitles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let vc = LWTextViewController()
        vc.model = models[index]
        return vc
    }
    
    
}

extension LWSubpagesView : JXSegmentedViewDelegate{
    
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}
