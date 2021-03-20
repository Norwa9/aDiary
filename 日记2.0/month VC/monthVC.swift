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
                configureDataSource(dataSource: diariesForMonth(forYear: selectedYear, forMonth: selectedMonth))
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
    var popoverView:filterMenu!
    var popover:Popover!
    //calendar
    fileprivate weak var calendar: FSCalendar!
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
        layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 95.0)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    var contentOffsetY:CGFloat = 0
    var cellCountLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 55, width: 50, height: 20))
    //data source
    var tableViewDiaryDataSource = [diaryInfo]()
    var filteredDiaries = [diaryInfo]()
    
    //异步
    func configureDataSource(dataSource:[diaryInfo?],configFilteredDiariesOnly:Bool = false){
//        DispatchQueue.global(qos: .background).async{ [self] in
            filteredDiaries.removeAll()
            for diary in dataSource{
                if diary != nil{
                    filteredDiaries.append(diary!)
                    print("configureDataSource,filteredDiaries.count:\(filteredDiaries.count)")
                }
            }
            filteredDiaries.reverse()
            if !configFilteredDiariesOnly{
                tableViewDiaryDataSource = filteredDiaries
            }
//        }
//        DispatchQueue.main.async{ [self] in
            //reload data
            collectionView.performBatchUpdates({
                let indexSet = IndexSet(integersIn: 0...0)
                self.collectionView.reloadSections(indexSet)
            }, completion: nil)
//        }
    }
    
    func configureUI(){
        //configure collection view
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(monthCell.self, forCellWithReuseIdentifier: monthCell.reusableID)
        collectionView.contentInset.top = 5//为了第一个cell的顶部阴影
        collectionView.contentInset.bottom = 140//解决最后一个cell显示不全的问题
        cellCountLabel.font = UIFont(name: "Noto Sans S Chinese", size: 14)
        cellCountLabel.center.x = collectionView.center.x
        cellCountLabel.alpha = 0
        view.addSubview(cellCountLabel)
        
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
        searchBar.placeholder = "查找所有日记"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.enablesReturnKeyAutomatically = true
        //自定义cancel按钮文本与颜色
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)], for: .normal)
        searchBar.delegate = self
        searchBar.alpha = 0
        view.addSubview(searchBar)
        filterButton = topbarButton(frame: CGRect(
                                        x: 0,y: 0,
                                        width: searchBar.frame.height,
                                        height: searchBar.frame.height))
        filterButton.center.x = topbar.button3.center.x
        filterButton.center.y = searchBar.center.y
        filterButton.image = UIImage(named: "filter")
        filterButton.alpha = 0
        filterButton.addTarget(self, action: #selector(filterButtonDidTapped(sender:)), for: .touchUpInside)
        filterButton.transform = CGAffineTransform(scaleX: 0, y: 0)
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
        calendar.firstWeekday = 2
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20)
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.eventDefaultColor = .black
        calendar.appearance.selectionColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.2509803922, alpha: 1)
        calendar.appearance.headerDateFormat = "yyyy年M月"
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        calendar.headerHeight = 0//移除年月份栏
        calendar.placeholderType = .none
        calendar.locale = Locale(identifier: "zh_CN")//设置周次为中文
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
    
    //MARK:-3个函数，配置back to current month button
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
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.backToCurMonthButton.frame = CGRect(x: 162, y: 650, width: 100, height: 40)
            } completion: { (_) in
                self.isShowingBackButton = true
            }
        }else{
            //隐藏
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.backToCurMonthButton.frame = CGRect(x: 162, y: 900, width: 100, height: 40)
            } completion: { (_) in
                self.isShowingBackButton = false
            }
        }
    }
    
    //popover
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.5)
        
        let arrowPoint = CGPoint(x: sender.frame.minX, y:sender.frame.maxY + topbar.frame.height)
        
        //popover view
        let viewSize = CGSize(width: 315, height:260 )
        popoverView = filterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: viewSize))
        popoverView.monthVC = self
        popoverView.keywords = searchBar.text
        
        let options = [
            .type(.auto),
            .cornerRadius(20.0),
          .animationIn(0.3),
//          .arrowSize(CGSize(width: 10, height: 10)),
            .springDamping(0.7),
          ] as [PopoverOption]
        popover = Popover(options: options, showHandler: nil, dismissHandler: {print("popover dismiss")})
//        popover.show(popoverView, fromView: sender)
        popover.show(popoverView, point: arrowPoint)
        
    }
    
    
    func animateCalendar(isShowing:Bool,plusDuration:TimeInterval = 0){
        if !isShowing{
            //1
            collectionView.decelerationRate = .init(rawValue: 0)
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
        case 3://切换搜索视图
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
            searchButtonImageView.image = UIImage(named: "back")
            topbar.tempLabel1.text = "搜索全部"
            topbar.tempLabel2.text = " "
            topbar.tempLabel1.sizeToFit()//更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            topbar.rectBar1.animateWidthChange(to: topbar.tempLabel1.frame.size.width)
            //更新数据:将tableViewDataSource设置为所有日记，同时清空FilterDiaries
            configureDataSource(dataSource: diariesForMonth(forYear: 0, forMonth: 0))
        }else{
            searchButtonImageView.image = UIImage(named: "search")
            topbar.tempLabel1.text = "\(selectedYear)年"
            topbar.tempLabel2.text = "\(selectedMonth)月"
            topbar.tempLabel1.sizeToFit()
            topbar.rectBar1.animateWidthChange(to: topbar.tempLabel1.frame.size.width)
            
            //更新数据
            configureDataSource(dataSource: diariesForMonth(forYear: selectedYear, forMonth: selectedMonth))
        }

        //切换搜索栏或月份栏
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.filterButton.transform = self.isFilterMode ?
                .identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.monthButtonContainer.alpha = self.isFilterMode ? 0:1
            self.searchBar.alpha = self.isFilterMode ? 1:0
            self.filterButton.alpha = self.isFilterMode ? 1:0
            if self.isFilterMode {
                self.monthButtonContainer.frame = self.searchBarFrame
            }else{
                self.searchBar.frame = self.monthButtonContainerFrame
            }
        } completion: { (_) in
            self.monthButtonContainer.frame = self.monthButtonContainerFrame
            self.searchBar.frame = self.searchBarFrame
        }

    }
    
    
}

extension monthVC:UICollectionViewDelegate,UICollectionViewDataSource{
    //MARK:-collection view
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
        cell.text = diary.content
//        cell.contentLabel.attributedText = loadAttributedString(date_string: diary.date!)
        cell.tags = diary.tags
        cell.dateLabel.text = diary.date! + "，" + getWeekDayFromDateString(string: diary.date!)
        cell.wordNum = diary.content.count
        cell.isLike = diary.islike
        cell.moodType = diary.mood
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        DataContainerSingleton.sharedDataContainer.selectedDiary = filteredDiaries[row]
        pageVC.slideToTodayVC(completion: nil)
    }
}

extension monthVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        print(y)
        cellCountLabel.text = "\(filteredDiaries.count)篇"
        cellCountLabel.sizeToFit()
        cellCountLabel.alpha = y<0 ? (-(y+5)/40) : 0
        
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

//        let y = scrollView.contentOffset.y
        if calendarIsShowing{
            if scrollView.contentOffset.y - contentOffsetY > 150{
                animateCalendar(isShowing: calendarIsShowing,plusDuration: 0.5)
            }
        }
    }
}

extension monthVC:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    //MARK:-点击日期事件
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateContainer = DataContainerSingleton.sharedDataContainer
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        print("选取日期:\(dateString)")
        if let selectedDiary = dateContainer.diaryDict[dateString]{
            dateContainer.selectedDiary = selectedDiary
            pageVC.slideToTodayVC(completion: nil)
        }else{
            print("该日期无日记")
        }
    }
    //MARK:-页面变化事件
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //获取当前页面月份
        print("calendarCurrentPageDidChange")
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!
        
        selectedYear = year
        selectedMonth = month
    }
    
    //MARK:-设置事件点·
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        formatter.dateFormat = "yyyy年M月d日"
        for diarydate in DataContainerSingleton.sharedDataContainer.diaryDict.keys{
            if diarydate == formatter.string(from: date){
                return 1
            }
        }
        return 0
    }
    
    //MARK:-给日期块着色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        formatter.dateFormat = "yyyy年M月d日"
        guard let eventDate = formatter.date(from: getTodayDate()) else{
            return nil
        }
        if date.compare(eventDate) == .orderedSame{
            return #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
        }
        return nil
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
        self.collectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.collectionView.reloadSections(indexSet)
                        }, completion: nil)
    }
    
    //根据搜索框信息更新filteredData
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //当搜索框为空，filteredData不展示内容。
        //当搜索框输入内容，将根据输入内容从data过滤内容到filteredData去展示
        filteredDiaries = searchText.isEmpty ? tableViewDiaryDataSource : tableViewDiaryDataSource.filter { (item: diaryInfo) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.content.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        //reload data animation
        self.collectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.collectionView.reloadSections(indexSet)
                        }, completion: nil)

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

extension monthVC{
    //MARK:-monthVC生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        configureDataSource(dataSource: diariesForMonth(forYear: selectedYear, forMonth: selectedMonth))
        
        //notificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(monthButtonsTapped(sender:)), name: NSNotification.Name("monthButtonsTapped"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("MonthVC viewDidAppear")
        
    }
}

