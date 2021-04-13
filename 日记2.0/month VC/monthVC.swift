//
//  monthVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import FSCalendar
import Popover

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
                configureBackButton()
                
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
       return button
    }()
    
    //views
    weak var topbar:topbarView!
    @IBOutlet weak var monthButtonContainer:UIView!
    var monthButtonContainerFrame:CGRect!
    var searchBar:UISearchBar!
    var searchBarFrame:CGRect!
    var isFilterMode:Bool = false
    var filterButton:topbarButton!
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
    var calendarHeight:CGFloat!
    var calendarHeightOriginFrame:CGRect!
    var formatter = DateFormatter()
    @IBOutlet weak var collectionViewTopInset: NSLayoutConstraint!
    var calendarIsShowing:Bool = false
    //collection view
    @IBOutlet weak var collectionView:UICollectionView!
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 44)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    var contentOffsetY:CGFloat = 0
    //data source
    var tableViewDiaryDataSource = [diaryInfo]()
    var filteredDiaries = [diaryInfo]()
    
    //读取某年某月的日记，或读取全部日记
    func configureDataSource(year:Int,month:Int){
        let dataSource = diariesForMonth(forYear: year, forMonth: month)
            filteredDiaries.removeAll()
            for diary in dataSource{
                if diary != nil{
                    filteredDiaries.append(diary!)
                }
            }
            filteredDiaries.reverse()
            tableViewDiaryDataSource = filteredDiaries
            reloadCollectionViewData()
    }
    
    //读取来自dataSource的日记
    //configFilteredDiariesOnly
    func configureDataSource(dataSource:[diaryInfo?]){
        filteredDiaries.removeAll()
        for diary in dataSource{
            if diary != nil{
                filteredDiaries.append(diary!)
            }
        }
        filteredDiaries.reverse()
//        tableViewDiaryDataSource = filteredDiaries
        reloadCollectionViewData()
    }
    
    func configureUI(){
        //configure collection view
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(monthCell.self, forCellWithReuseIdentifier: monthCell.reusableID)
        collectionView.contentInset.top = 5//为了第一个cell的顶部阴影
        collectionView.contentInset.bottom = 50//解决最后一个cell显示不全的问题
        collectionView.showsVerticalScrollIndicator = false
        
        //configure month buttons
        monthButtonContainerFrame = monthButtonContainer.frame
        monthButtonContainer.layer.cornerRadius = 10
        monthButtonContainer.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        monthButtonContainer.setupShadow(opacity: 1, radius: 4, offset: CGSize(width: 1, height: 1), color: UIColor.black.withAlphaComponent(0.35))
        let buttonDiameter:CGFloat = 25
        let insetX:CGFloat = 10
        let insetY:CGFloat = 7
        let pedding:CGFloat = (monthButtonContainer.frame.width - insetX * 2.0 - 12.0 * buttonDiameter) / 11.0
        for i in 0..<12{
            let x = insetX + buttonDiameter * CGFloat(i) + pedding * CGFloat(i)
            let y = insetY
            let button = monthButton(frame: CGRect(x: x, y: y, width: buttonDiameter, height: buttonDiameter))
            button.monthVC = self
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidSelected(sender:)), for: .touchUpInside)
            monthButtonContainer.addSubview(button)
            monthButtons.append(button)
        }
        
        //configure search Bar
        let searchBarWidth = monthButtonContainer.frame.size.width - 50
        let seachBarHeight = monthButtonContainer.frame.size.height
        searchBar = UISearchBar()
        searchBar.frame = CGRect(
            origin: monthButtonContainer.frame.origin,
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
        view.addSubview(searchBar)
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
        view.addSubview(filterButton)
        
        //configure FSCalendar
        calendarHeight = 300
        let calendarPedding:CGFloat = 0
        let calendarWidth = monthButtonContainer.frame.width - 2 * calendarPedding
        let calendar = FSCalendar(frame: CGRect(
                                    x: monthButtonContainer.frame.midX -  calendarWidth * 0.5,
                                    y: monthButtonContainer.frame.maxY - calendarHeight,
                                    width: calendarWidth,
                                    height: calendarHeight))
        calendarHeightOriginFrame = calendar.frame
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.scrollEnabled = false
        calendar.firstWeekday = 2
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1).withAlphaComponent(0.4)
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
        view.addSubview(calendar)
        view.sendSubviewToBack(calendar)
        view.sendSubviewToBack(collectionView)
        self.calendar = calendar
        calendar.alpha = 0
        
        //back to cur month button
        view.addSubview(backToCurMonthButton)
    }

    @objc func monthDidSelected(sender:monthButton){
        formatter.dateFormat = "yyyy-MM"
        let tappedMonth = sender.tag
        
        if !calendarIsShowing{
            if tappedMonth == selectedMonth{
                animateCalendar(isShowing: calendarIsShowing)//收回日历
            }else{
                calendar.setCurrentPage(formatter.date(from: "\(selectedYear)-\(tappedMonth)")!, animated: true)
                //同时调用calendarCurrentPageDidChange()
            }
        }else{
            animateCalendar(isShowing: calendarIsShowing)//展开日历
            if tappedMonth == selectedMonth{
                if(!monthButtons[selectedMonth - 1].hasSelected){
                    selectedMonth = tappedMonth
                }
            }else{
                calendar.setCurrentPage(formatter.date(from: "\(selectedYear)-\(tappedMonth)")!, animated: true)
                //同时调用calendarCurrentPageDidChange()
            }
        }
    }
    
//MARK:-返回本月按钮
    @objc func backToCurMonthButtonTapped(){
        calendar.select(curDate, scrollToDate: true)
    }
    
    func configureBackButton(){
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
        if toShow{
            //显示
            self.isShowingBackButton = true
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
                self.backToCurMonthButton.frame = CGRect(x: 162, y: 650, width: 100, height: 40)
            } completion: { (_) in
                
            }
        }else{
            //隐藏
            self.isShowingBackButton = false
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.backToCurMonthButton.frame = CGRect(x: 162, y: 900, width: 100, height: 40)
            } completion: { (_) in
                
            }
        }
    }
    
    //popover
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.5)
        
        let arrowPoint = CGPoint(x: sender.frame.minX, y:sender.frame.maxY + topbar.frame.height)
        
        //popover view
        let viewSize = CGSize(width: 315, height:440 )
        filterView = filterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: viewSize))
        filterView.monthVC = self
        filterView.keywords = searchBar.text
        searchBar.resignFirstResponder()
        
        popover.show(filterView, point: arrowPoint)
    }
    
    //展示，收回日历
    func animateCalendar(isShowing:Bool,plusDuration:TimeInterval = 0){
        if !isShowing{
            //展开日历
            //1
            calendarIsShowing = true
            collectionViewTopInset.constant += calendarHeight
            UIView.animate(withDuration: 0.5 + plusDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            } completion: { (_) in}
            //2
            UIView.animate(withDuration: 0.8 + plusDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.calendar.alpha = 1
                self.calendar.frame.origin = CGPoint(
                    x: self.calendarHeightOriginFrame.origin.x,
                    y: self.monthButtonContainer.frame.maxY + 5)
            } completion: { (_) in}
        }else{
            //收回
            //1
            calendarIsShowing = false
            collectionViewTopInset.constant -= calendarHeight
            UIView.animate(withDuration: 0.5 + plusDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.view.layoutIfNeeded()
            } completion: { (_) in}
            //2
            UIView.animate(withDuration: 0.8 + plusDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseIn) {
                self.calendar.alpha = 0
                self.calendar.frame.origin = self.calendarHeightOriginFrame.origin
            } completion: { (_) in
                self.collectionView.decelerationRate = .normal
            }
        }
    }
    
    @objc func monthButtonsTapped(sender: NSNotification){
        guard let button = sender.userInfo!["buttonTag"] as? topbarButton else{return}
        let tag = button.tag
        switch tag {
        case 2:
            let settingVC = storyboard?.instantiateViewController(identifier: "settingViewController") as! settingViewController
            present(settingVC, animated: true, completion: nil)
        case 3:
            //进入搜索模式
            switchToFilterView(button: button)
        default:
            break
        }
    }
    
    func switchToFilterView(button:topbarButton){
        isFilterMode.toggle()
        
        //关闭日历
        if calendarIsShowing{
            animateCalendar(isShowing: calendarIsShowing)
        }
        //隐藏或显示backButton
        configureBackButton()
        
        //searh图标是临时添加到button3上面的
        let searchButtonImageView  = button.viewWithTag(99) as! UIImageView
        if isFilterMode{
            //更新数据:将tableViewDataSource设置为所有日记，同时清空FilterDiaries
            configureDataSource(year: 0, month: 0)
            searchButtonImageView.image = UIImage(named: "back")
            topbar.tempLabel1.text = "搜索"
            topbar.tempLabel2.text = "共\(filteredDiaries.count)篇日记"
            topbar.tempLabel1.sizeToFit()//更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            topbar.tempLabel2.sizeToFit()
            topbar.rectBar1.animateWidthChange(to: topbar.tempLabel1.frame.size.width)
        }else{
            searchButtonImageView.image = UIImage(named: "search")?.withHorizontallyFlippedOrientation()
            topbar.tempLabel1.text = "\(selectedYear)年"
            topbar.tempLabel2.text = "\(selectedMonth)月"
            topbar.tempLabel1.sizeToFit()
            topbar.rectBar1.animateWidthChange(to: topbar.tempLabel1.frame.size.width)
            
            //更新数据
            configureDataSource(year: selectedYear, month: selectedMonth)
        }
        
        //切换searchbar / 12月份栏
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.monthButtonContainer.alpha = self.isFilterMode ? 0:1
            self.searchBar.alpha = self.isFilterMode ? 1:0
            self.filterButton.alpha = self.isFilterMode ? 1:0
        } completion: { (_) in
            
        }
    }
    
    
}

//MARK:-collection view
extension monthVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func reloadCollectionViewData(){
//        self.collectionView.performBatchUpdates({
//            let indexSet = IndexSet(integersIn: 0...0)
//            self.collectionView.reloadSections(indexSet)
//        }, completion: nil)
        
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()//没有这句，首次进入monthVC所有cell大小有误（？）
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
        
        cell.fillCell(diary: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        DataContainerSingleton.sharedDataContainer.selectedDiary = filteredDiaries[row]
        pageVC.slideToTodayVC(completion: nil)
    }
    
    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.isDragging else {return}
//        cell.transform = cell.transform.translatedBy(x: 0, y: 40)//平移效果
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)//缩放效果
        cell.alpha = 0.5
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
//            cell.transform = cell.transform.translatedBy(x: 0, y: -40)
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.alpha = 1
        } completion: { (_) in
            
        }
    }
    
    
    
    
}

//MARK:-ScrollView CollectionView
extension monthVC:UIScrollViewDelegate{
    //下拉显示日历
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        print("y:\(y)")
        guard !isFilterMode else{
            return
        }
        //展开日历
        if !calendarIsShowing && -y > 100 && !collectionView.isDragging{
            self.animateCalendar(isShowing: calendarIsShowing)
        }
        if calendarIsShowing && -y > 100 && !collectionView.isDecelerating{
            self.collectionView.isScrollEnabled = false
            self.animateCalendar(isShowing: calendarIsShowing)
            self.collectionView.isScrollEnabled = true
        }
//        if -y > 130 && collectionView.is
            
    }

}

//MARK:-FSCalendar DataScouce
extension monthVC:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        cell.date = date
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
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
//        print("选取日期:\(dateString)")
        if let selectedDiary = dateContainer.diaryDict[dateString]{
            dateContainer.selectedDiary = selectedDiary
            pageVC.slideToTodayVC(completion: nil)
        }else{
            //3,补日记
            let popoverAlert = customAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
            popoverAlert.delegate = self
            popoverAlert.dateString = dateString
            
            popover.show(popoverAlert, fromView: cell!)
        }
        
    }
    
    //取消点击cell
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //自定义选取动画
        print("didDeselect")
        self.configureVisibleCells()
    }
    
    // MARK: - 自定义点击日历cell效果
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        var selectionType = SelectionType.none
        if calendar.selectedDates.contains(date){
            selectionType = .single
        }else{
            selectionType = .none
        }
        
        if selectionType == .none{
            diyCell.selectionLayer.isHidden = true
            return
        }else{
            diyCell.selectionLayer.isHidden = false
            diyCell.selectionType = selectionType
        }
        
    }
    
    
    //页面变化事件
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //获取当前页面月份
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
            if diary.date == formatter.string(from: date) && diary.content.count != 0{
                return 1
            }
        }
        return 0
    }
    
    //event dot着色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        formatter.dateFormat = "yyyy年M月d日"
        for diarydate in DataContainerSingleton.sharedDataContainer.diaryDict.keys{
            if diarydate == formatter.string(from: date){
                let diary = DataContainerSingleton.sharedDataContainer.diaryDict[diarydate]
                if let islike = diary?.islike,islike == true{
                    return [.yellow]
                }
            }
        }
        return [.black]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        formatter.dateFormat = "yyyy年M月d日"
        let diaryDate = formatter.string(from: date)
        let diary = DataContainerSingleton.sharedDataContainer.diaryDict[diaryDate]
        if diary?.islike == true{
            return [.yellow]
        }else{
            return [.black]
        }
    }
    
    
}

extension monthVC:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        filteredDiaries = tableViewDiaryDataSource
        reloadCollectionViewData()
    }
    
    //根据搜索框信息更新filteredData
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //当搜索框为空，filteredData不展示内容。
        //当搜索框输入内容，将根据输入内容从data过滤内容到filteredData去展示
        filteredDiaries = searchText.isEmpty ? tableViewDiaryDataSource : tableViewDiaryDataSource.filter { (item: diaryInfo) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.content.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        //reload data
        reloadCollectionViewData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

//MARK:-monthVC生命周期
extension monthVC{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        configureDataSource(year: selectedYear, month: selectedMonth)
        
        //notificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(monthButtonsTapped(sender:)), name: NSNotification.Name("monthButtonsTapped"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("MonthVC viewDidAppear")
        
    }
}

