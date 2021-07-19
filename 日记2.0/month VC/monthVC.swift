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
            filteredDiaries = dataSource
            flowLayout.dateSource = filteredDiaries
            DispatchQueue.main.async {
                reloadCollectionViewData()
            }
        }
    }
    
    //MARK:-初始化UI
    func configureUI(){
        //MARK:-collectionView
        //configure collection view
        collectionView.backgroundColor = .white
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
        
        //back to cur month button
        view.addSubview(backToCurMonthButton)
        
        //
        self.initCalendarUI()
    }

    //MARK:-button事件
    ///按下月份按钮
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
    
    ///返回本月按钮
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
    ///更新UI
    ///如果新Model对象没有加入数据源，调用该方法不会展示新的Model对象
    func reloadCollectionViewData(forRow:Int = -1,animated:Bool = false){
        //print("reloadCollectionViewData,row:\(forRow)")
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
            self.calendar.reloadData()
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
        cell.fillCell(diary: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedDiary = filteredDiaries[row]
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        cell.showSelectionPrompt()
        
        pageVC.slideToTodayVC(selectedDiary: selectedDiary, completion: nil)
    }
    
    
    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging || isFilterMode{
            return
        }else{
            guard let cell = cell as? monthCell else{return}
//            cell.transform = cell.transform.translatedBy(x: 0, y: 20)//平移效果
//            cell.albumView.alpha = 0
//            cell.albumView.transform  = CGAffineTransform.init(translationX: 0, y: -20)
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: -50)
//            cell.transform3D = CATransform3DMakeTranslation(0, -50, 0)
            UIView.animate(withDuration: 0.7, delay: 0.1 * Double(indexPath.row), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut]) {
                cell.alpha = 1
//                cell.transform3D = CATransform3DIdentity
                cell.transform = .identity
//                cell.transform = cell.transform.translatedBy(x: 0, y: -20)
//                cell.albumView.alpha = 1
//                cell.albumView.transform  = cell.albumView.transform.translatedBy(x: 0, y: 20)
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
            topbar.tempLabel2.text = "共\(LWRealmManager.shared.localDatabase.count)篇，\(dataManager.shared.getTotalWordcount())字"
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

//MARK:-monthVC生命周期
extension monthVC{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}

