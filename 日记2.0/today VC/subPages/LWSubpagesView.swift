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
    
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: globalConstantsManager.shared.kScreenWidth, height: CGFloat(kSegmentedViewHeight)))
    var kSegmentedViewHeight = 30
    var segmentDataSource = JXSegmentedTitleDataSource()
    var segmentTitles = [String]()
    
    var curTextVC:LWTextViewController?
    var isDragging = false
    var popover:Popover!
    
    var models:[diaryInfo] = []{
        didSet{
            updateUI(currentIndex: currentPageIndex)
        }
    }
    
    ///初始页面
    var currentPageIndex:Int = 0
    var currentModel:diaryInfo?{
        get{
            if models.count >= currentPageIndex + 1{
                return models[currentPageIndex]
            }else{
                return nil
            }
        }
    }
    
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
            let pageIndex = model.date.parseDateSuffix()
            segmentTitles.append("\(pageIndex + 1)页")
        }
        segmentDataSource.titles = segmentTitles
        let userFont = userDefaultManager.customFont(withSize: 12)
        segmentDataSource.titleNormalFont = userFont.bold() ?? userFont
        segmentedView.reloadData()
        pagingView.reloadData()
        segmentedView.selectItemAt(index: currentIndex)
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
    
    private func initUI(){
        self.layer.masksToBounds = true
        
        //segmentedView
        segmentedView.delegate = self
        segmentDataSource.titleSelectedColor = .label
        segmentDataSource.titleNormalColor = .label
        segmentDataSource.titleNormalFont = userDefaultManager.customFont(withSize: 12)
        segmentDataSource.isTitleZoomEnabled = true
        segmentDataSource.itemSpacing = 10
        segmentDataSource.isItemSpacingAverageEnabled = false
        segmentedView.dataSource = segmentDataSource
        segmentedView.backgroundColor = .systemGray6
        segmentedView.listContainer = pagingView.listContainerView//列表和categoryView联动
        pagingView.mainTableView.isScrollEnabled = false
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

//MARK:-JXPagingViewDelegate
extension LWSubpagesView : JXPagingViewDelegate{
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        0
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        //print("mainTableView contentOffset : \(scrollView.contentOffset)")
        //print("mainTableView content height : \(scrollView.contentSize.height)")
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
        currentPageIndex = index
        let vc = LWTextViewController()
        vc.model = models[index]
        return vc
    }
    
    
}

//MARK:-JXSegmentedViewDelegate
extension LWSubpagesView : JXSegmentedViewDelegate{
    ///更新topView
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        guard index < self.models.count else {return}
        
        isDragging = false
        
        let model = models[index]
        todayVC.topView.model = model
        curTextVC = pagingView.validListDict[index] as? LWTextViewController
        
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        isDragging = true
    }
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}


//MARK:-targetAction
extension LWSubpagesView{
    @objc func manageMutiPages(_ sender:UIButton){
        guard let mainPage = mainPage else{
            return
        }
        let managePagesAlertView = ManagePagesAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
        
        //定义取消操作
        managePagesAlertView.cancelAction = {
            self.popover.dismiss()
        }
        
        // 创建页面设置
        let createOptVC = LWCreateOptionViewController(mode: .newPage)
        createOptVC.createPageAction = { [self] template in
            // template 是选定的模板
            var newPage:diaryInfo
            if let template = template{
                // 有模板，表示创建模板页面
                if let templatedNewPage = LWTemplateHelper.shared.createDiaryUsingTemplate(dateCN: mainPage.date, pageIndex: models.count, template: template){
                    newPage = templatedNewPage
                }else{
                    // 模板页面创建失败
                    return
                }
            }else{
                // 没有模板，表示创建空页面
                newPage = LWRealmManager.shared.createPage(withDate: mainPage.date, pageNumber: models.count)
            }
            models.append(newPage)
            if models.count > 2{
                //请求打分
                if userDefaultManager.requestReviewTimes % 2 == 0{
                    SKStoreReviewController.requestReview()
                    userDefaultManager.requestReviewTimes += 1
                }
            }
            updateUI(currentIndex: models.count - 1)
            createOptVC.dismiss(animated: true, completion: nil)
        }
        
        //定义创建页面操作
        managePagesAlertView.showCreateOptVC = {
            let todayVC = UIApplication.getTodayVC()
            todayVC?.present(createOptVC, animated: true, completion: nil)
        }
        
        
        
        //定义删除页面操作
        managePagesAlertView.deleteAction = { [self] in
            //主页面不能删
            guard let deleteDiary = models.last,models.count > 1 else{return}
            models.removeLast()
            DiaryStore.shared.delete(with: deleteDiary.id)
            
            //防止奔溃：
            todayVC.model = models.first//1.编辑器的model指向主页面
            UIApplication.getMonthVC()?.reloadMonthVC()//2.刷新cell的model指向主页面
            
            updateUI(currentIndex: 0)
        }
        
        popover.show(managePagesAlertView, fromView: sender)
    }
}
