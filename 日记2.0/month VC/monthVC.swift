//
//  monthVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import FSCalendar
import Popover
import MJRefresh
import RealmSwift

class monthVC: UIViewController {
    //MARK:-var
    var monthButtons = [monthButton]()
    var curDate = Date()
    var curDay:Int!
    var curMonth:Int!
    var curYear:Int!
    var selectedDay:Int!
    var selectedYear:Int!
    var selectedMonth:Int!
    
    //MARK:-UIComponents
    var isShowingBackButton = false
    var isCurrentMonth:Bool = true
    var backToCurMonthButton:UIButton!
    //topbar
    var topbar:topbarView!
    //topView
    var topView:UIView!///顶部栏：用来放置月份按钮和搜索栏
    var filterButton:topbarButton!
    var monthBtnStackView:UIView!
    var searchBar:UISearchBar!
    var isFilterMode:Bool = false
    //popover
    var filterView:filterMenu!
    var popover:Popover = {
        let options = [
            .type(.auto),
            .cornerRadius(10),
          .animationIn(0.3),
            .arrowSize(CGSize(width: 5, height: 5)),
            .springDamping(0.7),
          ] as [PopoverOption]
        return Popover(options: options, showHandler: nil, dismissHandler: nil)
    }()
    //calendar
    var lwCalendar: LWCalendar!
    let calendarHeight:CGFloat = 300
    var calendarHeightOriginFrame:CGRect!
    var formatter = DateFormatter()
    //collection view
    var collectionView:UICollectionView!
    var flowLayout:waterFallLayout!///瀑布流布局
    //data source
    var filteredDiaries = [diaryInfo]()
    var resultDiaries = [diaryInfo]()
    var footer:MJRefreshAutoNormalFooter!
    
    //MARK:-生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupConstraint()
        loadData()
        
    }
    
    func loadData(){
        self.curYear = getDateComponent(for: Date(), for: .year)
        self.curMonth = getDateComponent(for: Date(), for: .month)
        self.curDay = getDateComponent(for: Date(), for: .day)
        self.selectedYear = curYear
        self.selectedMonth = curMonth
        
        updateUI()
    }
    
    func updateUI(){
        //更新dataLable1
        topbar.dataLable1.text = "\(selectedYear!)年"
        topbar.dataLable1.sizeToFit()
        
        //更新dataLable2
        //更新数据源
        if selectedMonth > 0{
            topbar.dataLable2.text = "\(selectedMonth!)月"
            topbar.dataLable2.sizeToFit()
            monthButtons[selectedMonth - 1].animateBackgroundColor()
            configureDataSource(year: selectedYear, month: selectedMonth)
            adjustBackToCurrentMonthButton()
        }
        
        //更新返回本月按钮
        adjustBackToCurrentMonthButton()
    }
    
    //MARK:-初始化UI
    private func initUI(){
        //topBar
        topbar = topbarView(frame: .zero)
        
        //collection view
        flowLayout = waterFallLayout()
        flowLayout.columnNumber = layoutParasManager.shared.collectioncolumnNumber
        flowLayout.interitemSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.lineSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.dateSource = filteredDiaries
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.contentInset = layoutParasManager.shared.collectionEdgesInset
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(monthCell.self, forCellWithReuseIdentifier: monthCell.reusableID)
        collectionView.showsVerticalScrollIndicator = false
        
        //topView
        topView = UIView()
        topView.layer.cornerRadius = 10
        
        //monthBtnStackView
        monthBtnStackView = UIView()
        monthBtnStackView.layer.cornerRadius = 10
        monthBtnStackView.backgroundColor = .secondarySystemGroupedBackground
        monthBtnStackView.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        
        //search Bar
        searchBar = UISearchBar()
        searchBar.placeholder = "查找所有日记"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.enablesReturnKeyAutomatically = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .normal)
        searchBar.delegate = self
        searchBar.alpha = 0
        
        //filterButton
        filterButton = topbarButton(frame: .zero)
        filterButton.image = UIImage(named: "filter")
        filterButton.alpha = 0
        filterButton.addTarget(self, action: #selector(filterButtonDidTapped(sender:)), for: .touchUpInside)
        
        //back to cur month button
        backToCurMonthButton = UIButton()
        backToCurMonthButton.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
        backToCurMonthButton.layer.cornerRadius = 20
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 13)
        ]
        let string = "返回本月"
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        backToCurMonthButton.setAttributedTitle(attributedString, for: .normal)
        backToCurMonthButton.addTarget(self, action: #selector(backToCurMonthButtonTapped), for: .touchUpInside)
        backToCurMonthButton.frame.size = CGSize(width: 100, height: 40)
        backToCurMonthButton.setupShadow()
        
        //calendar
        lwCalendar = LWCalendar(frame: .zero)
        lwCalendar.dataSource = self
        lwCalendar.delegate = self
        
        
        
        self.view.addSubview(topbar)
        self.view.addSubview(topView)
        self.topView.addSubview(monthBtnStackView)
        self.topView.addSubview(searchBar)
        self.topView.addSubview(filterButton)
        self.view.addSubview(collectionView)
        self.view.addSubview(backToCurMonthButton)
        self.view.addSubview(lwCalendar)
    }
    
    
    //MARK:-auto layout
    private func setupConstraint(){
        topbar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(topbar.snp.bottom).offset(5)
            make.left.equalTo(view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(40)
            make.bottom.equalTo(collectionView.snp.top).offset(-5)
        }
        
        monthBtnStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(topView)
        }
        
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-50)
        }
        
        filterButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(searchBar.snp.right)
            make.size.equalTo(CGSize(width: 35, height: 35))
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        lwCalendar.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
        
        //获取到真实的frame后，布局月份按钮
        self.view.layoutIfNeeded()
        let buttonDiameter:CGFloat = 25
        let insetY:CGFloat = (40 - 25) / 2
        let pedding:CGFloat = (monthBtnStackView.frame.width - 12.0 * buttonDiameter) / 13.0
        for i in 0..<12{
            let x = buttonDiameter * CGFloat(i) + pedding * CGFloat(i+1)
            let y = insetY
            let button = monthButton(frame: CGRect(x: x, y: y, width: buttonDiameter, height: buttonDiameter))
            button.monthVC = self
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidTap(sender:)), for: .touchUpInside)
            monthButtons.append(button)
            monthBtnStackView.addSubview(button)
        }
    }
    
    

    //MARK:-button事件
    ///按下月份按钮
    @objc func monthDidTap(sender:monthButton){
        formatter.dateFormat = "yyyy-MM"
        let tappedMonth = sender.tag
        if tappedMonth == selectedMonth{
                //animateCalendar(isShowing: calendarIsShowing)
        }else{
            selectedMonth = tappedMonth
            updateUI()
            lwCalendar?.setCurrentPage(formatter.date(from: "\(selectedYear!)-\(tappedMonth)")!, animated: false)
            
        }
    }
    
    ///返回本月按钮
    @objc func backToCurMonthButtonTapped(){
        //刷新DataSource
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: curDate))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: curDate))!
        selectedYear = year
        selectedMonth = month
        updateUI()
        //跳转日历
        lwCalendar?.setCurrentPage(curDate, animated: false)
    }
    
    func adjustBackToCurrentMonthButton(){
        if selectedMonth != curMonth || selectedYear != curYear{
            if !isShowingBackButton{
                showBackButton(toShow: true)
            }else if isShowingBackButton && isFilterMode{
                showBackButton(toShow: false)
            }
        }else{
            showBackButton(toShow: false)
        }
    }
    
    func showBackButton(toShow:Bool){
        let screenHeight = UIScreen.main.bounds.height
        if toShow{
            //显示
            self.isShowingBackButton = true
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut) {
                self.backToCurMonthButton.frame.origin.y = screenHeight * 0.9
                self.backToCurMonthButton.center.x = self.view.center.x
            } completion: { (_) in
                
            }
        }else{
            //隐藏
            self.isShowingBackButton = false
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseIn) {
                self.backToCurMonthButton.frame.origin.y = screenHeight * 1.1
                self.backToCurMonthButton.center.x = self.view.center.x
            } completion: { (_) in
                
            }
        }
    }
    
    ///-popover
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.5)
        
        //popover view
        let viewSize = CGSize(width: 315, height:440 )
        filterView = filterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: viewSize))
        filterView.monthVC = self
        searchBar.resignFirstResponder()
        popover.show(filterView, fromView: filterButton)
    }
    
    ///topbar按钮触发事件
    func monthButtonsTapped(button: topbarButton){
        switch button.tag {
        case 1:
            //切换单双列展示
            layoutParasManager.shared.switchLayoutMode()
            button.switchLayoutModeIcon()
            reloadCollectionViewData(forRow: -1,animated: true)//刷新数据源，同时伴有动画效果
        case 2:
            //进入设置界面
            let settingVC = storyboard?.instantiateViewController(identifier: "settingViewController") as! settingViewController
            present(settingVC, animated: true, completion: nil)
        case 3:
            //进入搜索模式
            switchToFilterView(button: button)
        default:
            break
        }
    }
    
    
}

//MARK:-collectionView数据源和代理
extension monthVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //读取某年某月的日记，或读取全部日记
    func configureDataSource(year:Int,month:Int){
        print("configureDataSource")
        DispatchQueue.main.async { [self] in
            let dataSource = diariesForMonth(forYear: year, forMonth: month)
            filteredDiaries.removeAll()
            filteredDiaries = dataSource
            flowLayout.dateSource = filteredDiaries
            DispatchQueue.main.async {
                reloadCollectionViewData()
            }
        }
    }
    
    ///更新UI
    func reloadCollectionViewData(forRow:Int = -1,animated:Bool = false){
        if forRow == -1{
            if !animated{
                self.collectionView.reloadData()
                self.view.layoutIfNeeded()
                return
            }
            
            //暂时关闭按钮，防止切换月份导致多次performBatchUpdates
            self.view.isUserInteractionEnabled = false
            
            ///更新瀑布流布局
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
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
                self.view.isUserInteractionEnabled = true
            }
            
            self.view.layoutIfNeeded()//预加载cell，避免第一次进入collectionview加载带来的卡顿
        }else{
            self.collectionView.reloadItems(at: [IndexPath(row: forRow, section: 0)])
        }
    }
    
    ///从数据库重新检索数据，展示所有的最新数据
    ///用于接收到CloudKit通知刷新数据源
    func reloadMonthVC(){
        if isFilterMode{
            self.filter()
        }else{
            self.configureDataSource(year: selectedYear, month: selectedMonth)
            self.lwCalendar?.reloadData()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDiaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt monthCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCell.reusableID, for: indexPath) as! monthCell
        let row = indexPath.row
        let diary = filteredDiaries[row]
        cell.setViewModel(diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedDiary = filteredDiaries[row]
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        cell.bounceAnimation(usingSpringWithDamping: 0.8)
        
        let vc = storyboard?.instantiateViewController(identifier: "todayVC") as! todayVC
        vc.todayDiary = selectedDiary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging || isFilterMode{
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

//MARK:-MJRefresh
extension monthVC{
    func setupMJRefresh(isFitlerMode:Bool){
        if isFitlerMode{
            footer = MJRefreshAutoNormalFooter()
            footer.setRefreshingTarget(self, refreshingAction: #selector(loadMoreDiray))
            self.collectionView.mj_footer = footer
        }else{
            footer.removeFromSuperview()
        }
    }
    
    @objc func loadMoreDiray(){
        print("loadMoreDiray")
        var currentNum = self.filteredDiaries.count
        if currentNum < self.resultDiaries.count{
            currentNum += 10
            let dataNum = min(currentNum, self.resultDiaries.count)
            self.filteredDiaries = Array(self.resultDiaries.prefix(dataNum))
            self.flowLayout.dateSource = self.filteredDiaries
            footer.setTitle("点击或上拉加载更多(\(self.filteredDiaries.count)/\(self.resultDiaries.count))", for: .refreshing)
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




//MARK:-切换搜索界面
extension monthVC:UISearchBarDelegate{
    func switchToFilterView(button:topbarButton){
        isFilterMode.toggle()
        
        self.setupMJRefresh(isFitlerMode: isFilterMode)
        
        //隐藏或显示backButton
        adjustBackToCurrentMonthButton()
        
        //searh图标是临时添加到button3上面的
        if isFilterMode{//进入搜索模式
            self.filteredDiaries.removeAll()
            self.reloadCollectionViewData()
            button.image = UIImage(named: "back")
            topbar.dataLable1.text = "搜索"
            topbar.dataLable2.text = "共\(LWRealmManager.shared.localDatabase.count)篇，\(dataManager.shared.getTotalWordcount())字"
            topbar.dataLable1.sizeToFit()//更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            topbar.dataLable2.sizeToFit()
        }else{//退出搜索模式
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            filterModel.shared.clear()//移除所有的搜索参数
            button.image = UIImage(named: "search")?.withHorizontallyFlippedOrientation()
            topbar.dataLable1.text = "\(selectedYear!)年"
            topbar.dataLable2.text = "\(selectedMonth!)月"
            topbar.dataLable1.sizeToFit()
            //退出后重新显示当月日记
            configureDataSource(year: selectedYear, month: selectedMonth)
        }
        
        //切换动画
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.monthBtnStackView.alpha = self.isFilterMode ? 0:1
            self.searchBar.alpha = self.isFilterMode ? 1:0
            self.filterButton.alpha = self.isFilterMode ? 1:0
        } completion: { (_) in
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //“取消”按钮
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    //根据搜索框信息更新filteredData
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterModel.shared.searchText = searchText
        self.filter()
    }
    
    func filter(){
        DispatchQueue.main.async {[self] in
            
            let arr = filterDiary()//全局函数:实际上速度大概在0.5s左右
            
            DispatchQueue.main.async {
                resultDiaries = arr
                filteredDiaries = Array(resultDiaries.prefix(20))
                print("search results:\(filteredDiaries.count)")
                flowLayout.dateSource = filteredDiaries//提供布局的计算依据
                //更新collectionView
                reloadCollectionViewData()//如果数据源很多，将会很耗时！
                
                //更新topbar label
                var totalNum = 0
                for diary in resultDiaries{
                    totalNum += diary.content.count
                }
                topbar.dataLable2.text = "共\(resultDiaries.count)篇，\(totalNum)字"
            }
        }
    }
    
    func animateFilterButton(hasPara:Bool){
//        UIView.animate(withDuration: 0.2) {
//            self.filterButton.backgroundColor = hasPara ? APP_GREEN_COLOR() : .white
//        }
    }

}

//MARK:-context Menu
extension monthVC {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            //
            let shareAction = UIAction(title: NSLocalizedString("分享", comment: ""),
                                         image: UIImage(named: "share")) { action in
                                    self.performShare(indexPath)
                                }
            
            //
            let deleteAction = UIAction(title: NSLocalizedString("删除", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                        self.performDelete(indexPath)
                        }
            return UIMenu(title: "", children: [shareAction, deleteAction])
        }
        
        
        return config
    }
    
    func performShare(_ indexPath:IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        let share = shareVC(monthCell: cell)
        self.present(share, animated: true, completion: nil)
    }
    
    
    func performDelete(_ indexPath:IndexPath){
        let row = indexPath.item
        print("row:\(row)")
        let delteDiary = filteredDiaries[row]
        DiaryStore.shared.delete(with: delteDiary.id)
        
    }
}



