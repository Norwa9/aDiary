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

class monthVC: UIViewController {
    weak var pageVC:customPageViewController!
    //date
    var monthButtons = [monthButton]()
    var curDate = Date()
    var curDay:Int!
    var curMonth:Int!
    var curYear:Int!
    var selectedDay:Int!
    var selectedYear:Int = getDateComponent(for: Date(), for: .year){
        didSet{
            topbar.tempLabel1.text = "\(selectedYear)年"
            topbar.tempLabel1.sizeToFit()
        }
    }
    var selectedMonth:Int = getDateComponent(for: Date(), for: .month){
        didSet{
            //每次选取月份时：
            if selectedMonth > 0{
                topbar.tempLabel2.text = "\(selectedMonth)月"
                topbar.tempLabel2.sizeToFit()
                monthButtons[selectedMonth - 1].animateBackgroundColor()
                configureDataSource(year: selectedYear, month: selectedMonth)
                adjustBackToCurrentMonthButton()
            }
        }
    }
    var isShowingBackButton = false
    var isCurrentMonth:Bool = true
    let backToCurMonthButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
        button.layer.cornerRadius = 20
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 13)
        ]
        let string = "返回本月"
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(backToCurMonthButtonTapped), for: .touchUpInside)
        button.frame.size = CGSize(width: 100, height: 40)
        button.setupShadow()
       return button
    }()
    
    //views
    weak var topbar:topbarView!
    @IBOutlet weak var topView:UIView!///顶部栏：用来放置月份按钮和搜索栏
    @IBOutlet weak var containerHeightAnchor: NSLayoutConstraint!
    var filterButton:topbarButton!
    var monthButtonsContainer:UIView!
    var originContainerHeihgt:CGFloat!
    var searchBar:UISearchBar!
    var searchBarFrame:CGRect!
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
    weak var calendar: FSCalendar!
    let calendarHeight:CGFloat = 300
    var calendarHeightOriginFrame:CGRect!
    var formatter = DateFormatter()
    var calendarIsShowing:Bool = false
    var calendarScrollView:UIScrollView!
    //collection view
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var collectionViewTopInsetAnchor: NSLayoutConstraint!
    var originTopInset:CGFloat!
    var flowLayout:waterFallLayout!///瀑布流布局
    //data source
    var filteredDiaries = [diaryInfo]()
    var resultDiaries = [diaryInfo]()
    var footer:MJRefreshAutoNormalFooter!
    
    //读取某年某月的日记，或读取全部日记
    func configureDataSource(year:Int,month:Int){
        DispatchQueue.main.async { [self] in
            let dataSource = diariesForMonth(forYear: year, forMonth: month)
                filteredDiaries.removeAll()
                for diary in dataSource{
                    if diary != nil{
                        filteredDiaries.append(diary!)
                    }
                }
                filteredDiaries.reverse()//日期从大到小排列
                flowLayout.dateSource = filteredDiaries
            DispatchQueue.main.async {
                print("configure dataSource,reload data")
                reloadCollectionViewData()
            }
        }
    }
    
    func configureUI(){
        //MARK:-collectionView
        //configure collection view
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(monthCell.self, forCellWithReuseIdentifier: monthCell.reusableID)
        collectionView.contentInset = layoutParasManager.shared.collectionEdgesInset
        collectionView.showsVerticalScrollIndicator = false
        originTopInset = collectionViewTopInsetAnchor.constant
        
        flowLayout = waterFallLayout()
        flowLayout.columnNumber = layoutParasManager.shared.collectioncolumnNumber
        flowLayout.interitemSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.lineSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.dateSource = filteredDiaries
        collectionView.collectionViewLayout = flowLayout
        
        
        //MARK:-month Buttons月份按钮
        view.layoutIfNeeded()//更新约束，获取准确的self.topView.frame
        monthButtonsContainer = UIView(frame: self.topView.bounds)
        self.topView.addSubview(monthButtonsContainer)
        monthButtonsContainer.snp.makeConstraints { (make) in
            make.edges.equalTo(self.topView)
        }
        topView.layer.cornerRadius = 10
        monthButtonsContainer.layer.cornerRadius = 10
        monthButtonsContainer.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        monthButtonsContainer.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        let buttonDiameter:CGFloat = 25
        let insetY:CGFloat = 7
        let pedding:CGFloat = ( monthButtonsContainer.frame.width - 12.0 * buttonDiameter) / 13.0
        for i in 0..<12{
            let x = buttonDiameter * CGFloat(i) + pedding * CGFloat(i+1)
            let y = insetY
            let button = monthButton(frame: CGRect(x: x, y: y, width: buttonDiameter, height: buttonDiameter))
            button.monthVC = self
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidTap(sender:)), for: .touchUpInside)
            self.monthButtonsContainer.addSubview(button)
            monthButtons.append(button)
        }
        originContainerHeihgt = containerHeightAnchor.constant
        
        //MARK:-搜索框
        //configure search Bar
        let searchBarWidth =  monthButtonsContainer.frame.size.width - 50
        let seachBarHeight = monthButtonsContainer.frame.size.height
        searchBar = UISearchBar()
        searchBar.frame = CGRect(
            origin: .zero,
            size: CGSize(width: searchBarWidth, height: seachBarHeight
            )
        )
        searchBarFrame = searchBar.frame
        //自定义searchbar外观
        searchBar.placeholder = "查找所有日记"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.enablesReturnKeyAutomatically = true
        //自定义cancel按钮文本与颜色
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .normal)
        searchBar.delegate = self
        searchBar.alpha = 0
        self.topView.addSubview(searchBar)
        filterButton = topbarButton(frame: CGRect(
                                        x: 0,y: 0,
                                        width: searchBar.frame.height - 5,
                                        height: searchBar.frame.height - 5))
        filterButton.center.x = topbar.button3.center.x
        filterButton.center.y = searchBar.center.y
        filterButton.image = UIImage(named: "filter")
        filterButton.alpha = 0
        filterButton.addTarget(self, action: #selector(filterButtonDidTapped(sender:)), for: .touchUpInside)
//        filterButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.topView.addSubview(filterButton)
        
        //MARK:-日历
        //configure FSCalendar
        let calendarPedding:CGFloat = 10
        let calendarWidth = monthButtonsContainer.frame.width - 2 * calendarPedding
        let calendar = FSCalendar(frame: CGRect(
                                    x: (monthButtonsContainer.frame.width - calendarWidth) / 2,
                                    y: monthButtonsContainer.frame.maxY,
                                    width: calendarWidth,
                                    height: calendarHeight))
//        calendar.layer.borderWidth = 1
        calendarHeightOriginFrame = calendar.frame
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.scrollEnabled = true
        calendar.firstWeekday = 2
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .clear
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .black
        calendar.headerHeight = 0//移除年月份栏
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 17)
        calendar.appearance.titleFont = UIFont.appCalendarCellTitleFont()
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.eventSelectionColor = .black
        calendar.appearance.selectionColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.2509803922, alpha: 1)
        calendar.appearance.titleSelectionColor = APP_GREEN_COLOR()
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -5)
        calendar.appearance.eventDefaultColor = .black
        calendar.appearance.headerDateFormat = "yyyy年M月"
        calendar.locale = Locale(identifier: "zh_CN")//设置周次为中文
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        calendar.placeholderType = .none//仅显示当月日期cell
        formatter.dateFormat = "MM"
        curMonth = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "yyyy"
        curYear = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "dd"
        curDay = Int(formatter.string(from: calendar.currentPage))!
        selectedMonth = curMonth
        selectedYear = curYear
        selectedDay = curDay
        self.calendar = calendar
        calendar.alpha = 0
        self.monthButtonsContainer.addSubview(calendar)
        
        
        //back to cur month button
        view.addSubview(backToCurMonthButton)
    }

    @objc func monthDidTap(sender:monthButton){
        formatter.dateFormat = "yyyy-MM"
        let tappedMonth = sender.tag
        
        if !calendarIsShowing{
            if tappedMonth == selectedMonth{
                animateCalendar(isShowing: calendarIsShowing)//收回日历
            }else{
                calendar.setCurrentPage(formatter.date(from: "\(selectedYear)-\(tappedMonth)")!, animated: false)
                selectedMonth = tappedMonth//更新dateSouce
            }
        }else{
            if tappedMonth == selectedMonth{
                    animateCalendar(isShowing: calendarIsShowing)
            }else{
                calendar.setCurrentPage(formatter.date(from: "\(selectedYear)-\(tappedMonth)")!, animated: false)
                selectedMonth = tappedMonth//更新dateSouce
            }
        }
    }
    
//MARK:-返回本月按钮
    @objc func backToCurMonthButtonTapped(){
        //刷新DataSource
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: curDate))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: curDate))!
        selectedYear = year
        selectedMonth = month
        
        //跳转日历
        calendar.setCurrentPage(curDate, animated: false)
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
                self.backToCurMonthButton.frame.origin.y = screenHeight * 0.7
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
    
    //MARK:-popover
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.5)
        
        //popover view
        let viewSize = CGSize(width: 315, height:440 )
        filterView = filterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: viewSize))
        filterView.monthVC = self
        searchBar.resignFirstResponder()
        popover.show(filterView, fromView: filterButton)
    }
    
    //MARK:-展示，收回日历
    func animateCalendar(isShowing:Bool,plusDuration:TimeInterval = 0){
        if !isShowing{
            //展开日历
            //1
            calendarIsShowing = true
            containerHeightAnchor.constant = originContainerHeihgt + calendarHeight
            collectionViewTopInsetAnchor.constant = originTopInset + calendarHeight
            UIView.animate(withDuration: 0.5 + plusDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction]) {
                self.view.layoutIfNeeded()
            } completion: { (_) in}
            //2
            UIView.animate(withDuration: 0.8 + plusDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction]) {
                self.calendar.alpha = 1
                self.monthButtonsContainer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } completion: { (_) in
                
            }
        }else{
            //收回
            //1
            calendarIsShowing = false
            containerHeightAnchor.constant = originContainerHeihgt
            collectionViewTopInsetAnchor.constant = originTopInset
            UIView.animate(withDuration: 0.5 + plusDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseIn,.allowUserInteraction]) {
                self.view.layoutIfNeeded()
            } completion: { (_) in}
            //2
            UIView.animate(withDuration: 0.3 + plusDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseIn,.allowUserInteraction]) {
                self.calendar.alpha = 0
                self.monthButtonsContainer.backgroundColor =  #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            } completion: { (_) in
                
            }
        }
    }
    
    //MARK:-topbar按钮触发事件
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

//MARK:-collection view
extension monthVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func reloadCollectionViewData(forRow:Int = -1,animated:Bool = false){
        print("reloadCollectionViewData,row:\(forRow)")
        if forRow == -1{
            if !animated{
                self.collectionView.reloadData()
                self.view.layoutIfNeeded()
                return
            }
            
            //暂时关闭按钮，防止切换月份导致多次performBatchUpdates
            self.view.isUserInteractionEnabled = false
            
            ///更新瀑布流布局
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
                self.collectionView.performBatchUpdates({
                    //让cell以平滑动画移动到新位置上去
                    self.collectionView.reloadData()
                    
                    //让cell以平滑动画更新size
                    for cell in self.collectionView.visibleCells{
                        let cell = cell as! monthCell
                        cell.updateWCons()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDiaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCell.reusableID, for: indexPath) as! monthCell
        let row = indexPath.row
        let diary = filteredDiaries[row]
        print("dequeue monthCell,\(diary.date!)")
        cell.fillCell(diary: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        DataContainerSingleton.sharedDataContainer.selectedDiary = filteredDiaries[row]
        
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        cell.showSelectionPrompt()
        
        pageVC.slideToTodayVC(completion: nil)
    }
    
    
    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging || isFilterMode{
            return
        }else{
            guard let cell = cell as? monthCell else{return}
            cell.transform = cell.transform.translatedBy(x: 0, y: 20)//平移效果
//            cell.albumView.alpha = 0
            cell.albumView.transform  = CGAffineTransform.init(translationX: 0, y: -20)
            UIView.animate(withDuration: 0.7, delay: 0.1 * Double(indexPath.row), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut]) {
                cell.transform = cell.transform.translatedBy(x: 0, y: -20)
//                cell.albumView.alpha = 1
                cell.albumView.transform  = cell.albumView.transform.translatedBy(x: 0, y: 20)
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

//MARK:-ScrollView CollectionView
extension monthVC:UIScrollViewDelegate{
    ///下拉显示日历
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if originContainerHeihgt == nil {return}
        let y = -scrollView.contentOffset.y
        //print("offset:\(y)")
        guard !isFilterMode,y > 0 else{
            return
        }
        
        ///展开日历
        if !calendarIsShowing{
            if y < collectionView.contentInset.top{
                return//往上滑时不改变月份面板的高度
            }
            /*
             content实际的滑动距离：(y - collectionView.contentInset.top)
             */
            containerHeightAnchor.constant = originContainerHeihgt + (y - collectionView.contentInset.top)
            view.layoutIfNeeded()
            //展开日历
            if y > 100 && !collectionView.isDragging{
                self.animateCalendar(isShowing: calendarIsShowing)
            }
        }
        
        ///收回日历
        if calendarIsShowing{
            if y > 100 && !collectionView.isDecelerating{
               self.collectionView.isScrollEnabled = false
               self.animateCalendar(isShowing: calendarIsShowing)
               self.collectionView.isScrollEnabled = true
           }
        }
    }

}

//MARK:-FSCalendar数据源
extension monthVC:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,ExtendedFSCalendarDelegate{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        
        cell.initUI(forDate: date)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("FSCalendar willDisplay cell")
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    //点击cell
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        //1、显示绿色圆环
        self.configureVisibleCells()
        
        //2、如果选中未来日期，摇晃cell
        if date.compare(Date()) == .orderedDescending{
            cell?.shake()
            return
        }
        
        //2、进入日记
        let dateContainer = DataContainerSingleton.sharedDataContainer
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        if let selectedDiary = dateContainer.diaryDict[dateString]{
            dateContainer.selectedDiary = selectedDiary
            pageVC.slideToTodayVC(completion: nil)
        }else{
            //3,补日记
            let popoverAlert = customAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
            popoverAlert.dateString = dateString
            
            popover.show(popoverAlert, fromView: cell!)
        }
        
    }
    
    //取消点击cell
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //自定义选取动画
//        print("didDeselect")
//        self.configureVisibleCells()
    }
    
// MARK: - FSCalendar自定义外观
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        if calendar.selectedDates.contains(date){
            cell.selectionType = .single
        }else{
            cell.selectionType = .none
        }
        
    }
    
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//    }
    
    func didEndDecelerating(calendar: FSCalendar) {
        /*
         calendarCurrentPageDidChange存在问题：页面是willchange时调用而不是didchange时调用
         为此使用网友提供的ExtendedFSCalendarDelegate。
         通过didEndDecelerating来真正实现page didchange时调用
        */
        //获取当前页面月份
        print("didEndDecelerating(calendar: FSCalendar)")
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!

        selectedYear = year
        selectedMonth = month
    }
    
    //event dot数量
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        formatter.dateFormat = "yyyy年M月d日"
        let dict = DataContainerSingleton.sharedDataContainer.diaryDict

        for diary in dict.values{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.content.count != 0{
                return 1
            }
        }
        return 0
    }
    //事件点默认颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        formatter.dateFormat = "yyyy年M月d日"
        let dict = DataContainerSingleton.sharedDataContainer.diaryDict
        for diary in dict.values{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.islike{
                return [.yellow]
            }
        }
        return [.black]
    }
    //事件点选取状态的颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [APP_GREEN_COLOR()]
    }
    
    
}

//来源：
extension FSCalendar: UIScrollViewDelegate {
public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
(delegate as? ExtendedFSCalendarDelegate)?.didEndDecelerating(calendar: self)
}
}

protocol ExtendedFSCalendarDelegate: FSCalendarDelegate {
func didEndDecelerating(calendar: FSCalendar)
}

extension ExtendedFSCalendarDelegate {
func didEndDecelerating(calendar: FSCalendar) { }
}

//MARK:-切换搜索界面
extension monthVC:UISearchBarDelegate{
    func switchToFilterView(button:topbarButton){
        isFilterMode.toggle()
        
        self.setupMJRefresh(isFitlerMode: isFilterMode)
        
        //关闭日历
        if calendarIsShowing{
            animateCalendar(isShowing: calendarIsShowing)
        }
        //隐藏或显示backButton
        adjustBackToCurrentMonthButton()
        
        //searh图标是临时添加到button3上面的
        let searchButtonImageView  = button.viewWithTag(99) as! UIImageView
        if isFilterMode{//进入搜索模式
            self.filteredDiaries.removeAll()
            self.reloadCollectionViewData()
            searchButtonImageView.image = UIImage(named: "back")
            topbar.tempLabel1.text = "搜索"
            topbar.tempLabel2.text = "共\(DataContainerSingleton.sharedDataContainer.diaryDict.count)篇，\(DataContainerSingleton.sharedDataContainer.getTotalWordcount())字"
            topbar.tempLabel1.sizeToFit()//更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            topbar.tempLabel2.sizeToFit()
        }else{//退出搜索模式
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            filterModel.shared.clear()//移除所有的搜索参数
            searchButtonImageView.image = UIImage(named: "search")?.withHorizontallyFlippedOrientation()
            topbar.tempLabel1.text = "\(selectedYear)年"
            topbar.tempLabel2.text = "\(selectedMonth)月"
            topbar.tempLabel1.sizeToFit()
            //退出后重新显示当月日记
            configureDataSource(year: selectedYear, month: selectedMonth)
        }
        
        //切换动画
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.monthButtonsContainer.alpha = self.isFilterMode ? 0:1
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
        DispatchQueue.global(qos: .default).async {[self] in
            resultDiaries = filterDiary()//全局函数:实际上速度大概在0.5s左右
            filteredDiaries = Array(resultDiaries.prefix(20))
            flowLayout.dateSource = filteredDiaries//提供布局的计算依据
            
            DispatchQueue.main.async {
                //更新collectionView
                reloadCollectionViewData()//如果数据源很多，将会很耗时！
                
                //更新topbar label
                var totalNum = 0
                for diary in resultDiaries{
                    totalNum += diary.content.count
                }
                topbar.tempLabel2.text = "共\(resultDiaries.count)篇，\(totalNum)字"
            }
        }
    }
    
    func animateFilterButton(hasPara:Bool){
//        UIView.animate(withDuration: 0.2) {
//            self.filterButton.backgroundColor = hasPara ? APP_GREEN_COLOR() : .white
//        }
    }

}

//MARK:-monthVC生命周期
extension monthVC{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}

