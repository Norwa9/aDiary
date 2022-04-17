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
    //MARK: -var
    var monthButtons = [monthButton]()
    var curDate = Date()
    var curDay:Int!
    var curMonth:Int!
    var curYear:Int!
    var selectedDay:Int!
    var selectedYear:Int!
    var selectedMonth:Int!
    
    //MARK: -UIComponents
    var isShowingBackButton = true
    var isCurrentMonth:Bool = true
    var floatButton:UIButton!
    //topbar
    var topbar:topbarView!
    //topView
    var topView:UIView!///顶部栏：用来放置月份按钮和搜索栏
    var filterButton:topbarButton!
    var monthBtnStackView:UIView!
    var searchBar:UISearchBar!
    var isFilterMode:Bool = false
    let kTopViewHeight:CGFloat = 40
    //calendar
    var lwCalendar: LWCalendar!
    var formatter = DateFormatter()
    var isShowingCalendar:Bool = false
    let kCalendarHeight:CGFloat = 300
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
    //collection view
    var collectionView:UICollectionView!
    var flowLayout:waterFallLayout!///瀑布流布局
    var blurEffectView:UIVisualEffectView!
    let kBlurEffectViewHeight:CGFloat = 120
    //data source
    var filteredDiaries = [diaryInfo]()
    var resultDiaries = [diaryInfo]()
    var footer:MJRefreshAutoNormalFooter!
    //编辑器
    var editorVC:todayVC!
    var selectedCell:monthCell!
    
    //MARK: -生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupConstraint()
        addObservers()
        loadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let vc = WhatsNewHelper.getWhatsNewViewController(){
            self.present(vc, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                vc.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    func loadData(){
        //预加载todayVC
        editorVC = todayVC()
        let _ = editorVC.view
        editorVC.modalPresentationStyle = .custom
        editorVC.transitioningDelegate = self
        
        //设置基础数据
        self.curYear = getDateComponent(for: Date(), for: .year)
        self.curMonth = getDateComponent(for: Date(), for: .month)
        self.curDay = getDateComponent(for: Date(), for: .day)
        self.selectedYear = curYear
        self.selectedMonth = curMonth
        
        updateUI()
    }
    
    ///selectedYear或者selectedMonth更新后，调用updateUI更新视图界面
    func updateUI(){
        //更新dataLable1
        topbar.dataLable1.text = "\(selectedYear!)年"
        topbar.dataLable1.sizeToFit()
        
        if selectedMonth > 0{
            //更新dataLable2
            topbar.dataLable2.text = "\(selectedMonth!)月"
            topbar.dataLable2.sizeToFit()
            
            //更新collectionView
            configureDataSource(year: selectedYear, month: selectedMonth)
            
            //更新日历
            formatter.dateFormat = "yyyy-MM"
            lwCalendar?.setCurrentPage(formatter.date(from: "\(selectedYear!)-\(selectedMonth!)")!, animated: true)
            
            //更新月份按钮
            updateMonthBtns()
            
            //更新返回按钮
            updateFloatButton()
            return
        }
        
        //更新返回本月按钮
        updateFloatButton()
        
        
    }
    
    ///添加通知
    private func addObservers(){
        //屏幕旋转通知
        //NotificationCenter.default.addObserver(self, selector: #selector(onContainerSizeChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    //更新monthButtons的点亮状态
    private func updateMonthBtns(){
        for button in monthButtons{
            if button.hasSelected{
                button.animateBackgroundColor()
            }
            
            if button.tag == selectedMonth{
                button.animateBackgroundColor()
            }
        }
    }
    
    
    //MARK: -初始化UI
    private func initUI(){
        // 初始化appSize
        // 当在iPad上App以分屏方式启动时，初始的大小不能取自UIScreen.main，那样是整个设备屏幕大小。
        // 通过autolayout获取正确的初始大小。
        globalConstantsManager.shared.appSize = self.view.bounds.size
        
        //设置深色模式
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let interfaceStyle = UIUserInterfaceStyle(rawValue: userDefaultManager.appearanceMode){
            scene.window?.overrideUserInterfaceStyle = interfaceStyle
        }
        
        self.view.backgroundColor = LWColorConstatnsManager.LWSoftBGColor
        //topBar
        topbar = topbarView(frame: .zero)
        
        //collection view
        flowLayout = waterFallLayout()
        flowLayout.columnNumber = layoutParasManager.shared.collectioncolumnNumber
        flowLayout.interitemSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.lineSpacing = layoutParasManager.shared.collectionLineSpacing
        flowLayout.dateSource = filteredDiaries
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = LWColorConstatnsManager.LWSoftBGColor
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
        monthBtnStackView.backgroundColor = monthBtnStackViewDynamicColor
        monthBtnStackView.setupShadow()
        
        for i in 0..<12{
            let button = monthButton(frame: .zero)
            button.monthVC = self
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidTap(sender:)), for: .touchUpInside)
            monthButtons.append(button)
            monthBtnStackView.addSubview(button)
        }
        
        //calendar
        lwCalendar = LWCalendar(frame: .zero)
        lwCalendar.dataSource = self
        lwCalendar.delegate = self
        lwCalendar.alpha = 0
        
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
        floatButton = UIButton()
        floatButton.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
        floatButton.layer.cornerRadius = 20
        floatButton.setupShadow()
        floatButton.addTarget(self, action: #selector(floatButtonDidTapped), for: .touchUpInside)
        
        
        
        self.view.addSubview(topbar)
        self.view.addSubview(topView)
        self.view.addSubview(monthBtnStackView)
        self.monthBtnStackView.addSubview(lwCalendar)
        self.topView.addSubview(searchBar)
        self.topView.addSubview(filterButton)
        self.view.addSubview(collectionView)
        self.view.addSubview(floatButton)
        //bottom gradient view
        layoutBottomGradientView()
        
    }
    
    ///布局底部渐变图层
    private func layoutBottomGradientView(){
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
        if UITraitCollection.current.userInterfaceStyle == .dark{
            blurEffectView.alpha = 0
        }else{
            blurEffectView.alpha = 1
        }
        
        blurEffectView.frame = CGRect(
            x:0,
            y:globalConstantsManager.shared.kScreenHeight - kBlurEffectViewHeight,
            width: globalConstantsManager.shared.kScreenWidth,
            height: kBlurEffectViewHeight);
        let gradientLayer = CAGradientLayer()//底部创建渐变层
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.label.cgColor]
        gradientLayer.frame = blurEffectView.bounds
        gradientLayer.locations = [0,0.9,1]
        blurEffectView.layer.mask = gradientLayer
        self.view.addSubview(blurEffectView)
    }
    
    //MARK: -auto layout
    private func setupConstraint(){
        topbar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(topbar.snp.bottom).offset(5)
            make.left.equalTo(view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(kTopViewHeight)
            make.bottom.equalTo(collectionView.snp.top).offset(-5)
        }
        
        monthBtnStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(topView)
        }
        
        lwCalendar.snp.makeConstraints { (make) in
            //初始时calendar高度被挤压为0
            make.top.equalToSuperview().offset(kTopViewHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
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
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        floatButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 100, height: 40))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        
        let kButtonDiameter = monthButton.monthButtonDiameter // 按钮的高度
        let insetY:CGFloat = (kTopViewHeight - kButtonDiameter) / 2
        if UIDevice.current.userInterfaceIdiom == .phone{
            // iPhone上使用frame 布局monthButtons
            self.view.layoutIfNeeded()//获取到真实的frame
            let padding:CGFloat = (monthBtnStackView.frame.width - 12.0 * kButtonDiameter) / 13.0
            for i in 0..<12{
                let x = kButtonDiameter * CGFloat(i) + padding * CGFloat(i+1)
                let y = insetY
                monthButtons[i].frame = CGRect(x: x, y: y, width: kButtonDiameter, height: kButtonDiameter)
            }
        }else{
            // iPad上使用autoLayout
            let padding:CGFloat = (globalConstantsManager.shared.kScreenWidth - 12 * kButtonDiameter) / 13
            for i in 0..<12{
                let button = monthButtons[i]
                let offset:CGFloat = (CGFloat(i) - 5.5) * kButtonDiameter + (CGFloat(i) - 5.5) * padding
                button.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(insetY)
                    make.size.equalTo(CGSize(width: kButtonDiameter, height: kButtonDiameter))
                    make.centerX.equalTo(monthBtnStackView.snp.centerX).offset(offset)
                }
            }
        }
        
    }

    //MARK: -action target
    ///按下月份按钮
    @objc func monthDidTap(sender:monthButton){
        let tappedMonth = sender.tag
        if tappedMonth == selectedMonth{
            
        }else{
            selectedMonth = tappedMonth
            updateUI()
        }
    }
    
    /// 显示日历
     func toggleCalendar(){
        isShowingCalendar.toggle()
        
        let newHeihgt = isShowingCalendar ? (kTopViewHeight + kCalendarHeight) : kTopViewHeight
        
        topView.snp.updateConstraints { (update) in
            update.height.equalTo(newHeihgt)
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            self.lwCalendar.alpha = self.isShowingCalendar ? 1 : 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            
        }
        
    }
    
    //MARK: 进入今日
    @objc func floatButtonDidTapped(){
        if isCurrentMonth{
            formatter.dateFormat = "yyyy年M月d日"
            let todayDateString = GetTodayDate()
            let predicate = NSPredicate(format: "date = %@", todayDateString)
            if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
                presentEditorVC(withViewModel: selectedDiary)
            }else{
                let createOptVC = LWCreateOptionViewController(mode: .newDay)
                self.present(createOptVC, animated: true, completion: nil)
            }
        }else{
            //回到本月
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
        
    }
    
    ///返回按钮的显示与否
    func updateFloatButton(){
        var title:String
        var colors:(UIColor,UIColor) // 背景、字体颜色
        if selectedMonth != curMonth || selectedYear != curYear{
            isCurrentMonth = false
            title = "返回本月"
            colors.0 = .white
            colors.1 = .black
        }else{
            isCurrentMonth = true
            title = "进入今日"
            colors.0 = UIColor.label
            colors.1 = UIColor.systemBackground
        }
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: colors.1,
            .font: appDefault.defaultFont(size: 14)
        ]
        let attributedString = NSAttributedString(string: title, attributes: titleAttributes)
        UIView.animate(withDuration: 0.3) {
            self.floatButton.backgroundColor = colors.0
            self.floatButton.setAttributedTitle(attributedString, for: .normal)
        }
        
        
    }
    
    ///-popover
    @objc func filterButtonDidTapped(sender:topbarButton){
        sender.bounceAnimation(usingSpringWithDamping: 0.8)
        
        //popover view
        let viewSize = CGSize(width: 315, height:440 )
        filterView = filterMenu(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: viewSize))
        filterView.monthVC = self
        searchBar.resignFirstResponder()
        popover.show(filterView, fromView: filterButton)
    }
    
    //MARK:  topbar按钮触发事件
    func topToolButtonTapped(button: topbarButton){
        switch button.tag {
        case 0:
            toggleCalendar()
        case 1:
            //切换单双列展示
            layoutParasManager.shared.switchLayoutMode()
            button.switchLayoutModeIcon()
            reloadCollectionViewData(forRow: -1,animated: true)//刷新数据源，同时伴有动画效果
        case 2:
            //进入设置界面
            let settingVC = LWSettingViewController()
            present(settingVC, animated: true, completion: nil)
        case 3:
            //进入搜索模式
            switchToFilterView(button: button)
        default:
            break
        }
    }
    
    
}

//MARK: -collectionView数据源和代理
extension monthVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //读取某年某月的日记，或读取全部日记
    func configureDataSource(year:Int,month:Int){
        //print("configureDataSource")
        let dataSource = diariesForMonth(forYear: year, forMonth: month)
        filteredDiaries.removeAll()
        filteredDiaries = dataSource
        flowLayout.dateSource = filteredDiaries
        reloadCollectionViewData()
    }
    
    ///更新UI
    ///parameter:
    func reloadCollectionViewData(forRow:Int = -1,animated:Bool = false,animationDuration:TimeInterval = 1.0){
        if forRow == -1{
            if !animated{
                self.collectionView.reloadData()
                self.view.layoutIfNeeded()
                return
            }
            
            //暂时关闭按钮，防止切换月份导致多次performBatchUpdates
            self.view.isUserInteractionEnabled = false
            
            ///更新瀑布流布局
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction]) {
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
            if isFilterMode{
                self.collectionView.reloadData()
            }else{
                self.collectionView.reloadItems(at: [IndexPath(row: forRow, section: 0)])
            }
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
        //print("cellForItemAt monthCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCell.reusableID, for: indexPath) as! monthCell
        let row = indexPath.row
        let diary = filteredDiaries[row]
        cell.setViewModel(diary)
        cell.cellRow = row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedDiary = filteredDiaries[row]
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        selectedCell = collectionView.cellForItem(at: indexPath) as? monthCell
        
        //点击动画
        cell.bounceAnimation(usingSpringWithDamping: 0.8)
        cell.showSelectionPrompt()
        
        presentEditorVC(withViewModel: selectedDiary)
    }
    
    func presentEditorVC(withViewModel viewModel:diaryInfo){
        guard self.presentedViewController == nil else { return }
        guard editorVC.isBeingPresented == false else { return }
        editorVC.model = viewModel
        self.present(editorVC, animated: true, completion: nil)
    }
    
    
    //滑动时cell的动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging || isFilterMode || collectionView.contentOffset.y > globalConstantsManager.shared.kScreenHeight{
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

//MARK: -MJRefresh
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




//MARK: -切换搜索界面
extension monthVC:UISearchBarDelegate{
    func switchToFilterView(button:topbarButton){
        isFilterMode.toggle()
        
        //配置下拉刷新控件
        self.setupMJRefresh(isFitlerMode: isFilterMode)
        
        //隐藏或显示日历
        if isShowingCalendar{
            toggleCalendar()
        }
        //隐藏或显示backButton
        updateFloatButton()
        
        //searh图标是临时添加到button3上面的
        if isFilterMode{//进入搜索模式
            self.filteredDiaries.removeAll()
            self.reloadCollectionViewData()
            button.image = UIImage(named: "back")
            topbar.dataLable1.text = "搜索"
            topbar.dataLable2.text = "共\(LWRealmManager.shared.localDatabase.count)篇，\(dataManager.shared.getTotalWordcount())字"
            topbar.dataLable1.sizeToFit()//更新tempLabel1的宽度，使得rectbar1能够正确匹配它的长度
            topbar.dataLable2.sizeToFit()
            topbar.forwardBtn.alpha = 0
            topbar.backwordBtn.alpha = 0
        }else{//退出搜索模式
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            filterHelper.shared.clear()//移除所有的搜索参数
            button.image = UIImage(named: "search")
            topbar.dataLable1.text = "\(selectedYear!)年"
            topbar.dataLable2.text = "\(selectedMonth!)月"
            topbar.dataLable1.sizeToFit()
            topbar.forwardBtn.alpha = 1
            topbar.backwordBtn.alpha = 1
            //退出后重新显示当月日记
            configureDataSource(year: selectedYear, month: selectedMonth)
        }
        
        //切换动画
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
            self.topbar.button0.alpha = self.isFilterMode ? 0:1
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

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        filterHelper.shared.searchText = searchBar.text ?? ""
        filter()
    }
    
    func filter(){
        filterHelper.shared.filter { [self] results,num,wordCount in
            resultDiaries = results
            filteredDiaries = Array(resultDiaries.prefix(20))
            print("search results:\(filteredDiaries.count)")
            flowLayout.dateSource = filteredDiaries//提供布局的计算依据
            //更新collectionView
            reloadCollectionViewData()//如果数据源很多，将会很耗时！
            //更新topbar label
            topbar.dataLable2.text = "共\(num)篇，\(wordCount)字"
            
        }
    }
    
    func animateFilterButton(hasPara:Bool){
//        UIView.animate(withDuration: 0.2) {
//            self.filterButton.backgroundColor = hasPara ? APP_GREEN_COLOR() : .white
//        }
    }

}

//MARK:  -context Menu
extension monthVC {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            //
            let shareDiaryAction = UIAction(title: NSLocalizedString("保存日记为图片", comment: ""),
                                         image: UIImage(named: "share")) { action in
                                    self.performDiaryShare(indexPath)
                                }
            let shareSummaryAction = UIAction(title: NSLocalizedString("保存摘要为图片", comment: ""),
                                         image: UIImage(named: "share")) { action in
                                    self.performSummaryShare(indexPath)
                                }
            
            //
            let deleteAction = UIAction(title: NSLocalizedString("删除", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                        self.performDelete(indexPath)
                        }
            return UIMenu(title: "", children: [shareDiaryAction, shareSummaryAction,deleteAction])
        }
        
        
        return config
    }
    
    func performDiaryShare(_ indexPath:IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        let share = shareVC(monthCell: cell)
        self.present(share, animated: true, completion: nil)
    }
    
    func performSummaryShare(_ indexPath:IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! monthCell
        let summaryImage = cell.asImage(inset: -5) // -5是为了截到cell周围的阴影
        LWImageSaver.shared.saveImage(image: summaryImage)
    }
    
    
    func performDelete(_ indexPath:IndexPath){
        let ac = UIAlertController(title: "是否删除此篇日记？", message: "该日期下所有日记都会被删除", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [self] _ in
            let row = indexPath.item
            let cellModel = filteredDiaries[row]
            DiaryStore.shared.deleteAllPage(withPageID: cellModel.id)
        }))
        self.present(ac, animated: true, completion: nil)
    }
}
//MARK:  -切换深色模式监听事件
extension monthVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if UITraitCollection.current.userInterfaceStyle == .dark{
            blurEffectView.alpha = 0
        }else{
            blurEffectView.alpha = 1
        }
    }

}

//MARK:  -屏幕旋转
extension monthVC{
    @objc private func onContainerSizeChanged(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            print("!= ipad")
            return
        }

        //1.更新month Buttons
        let kButtonDiameter = monthButton.monthButtonDiameter
        let padding:CGFloat = (globalConstantsManager.shared.kScreenWidth - 12 * kButtonDiameter) / 13
        for i in 0..<12{
            let button = monthButtons[i]
            let offset:CGFloat = (CGFloat(i) - 5.5) * kButtonDiameter + (CGFloat(i) - 5.5) * padding
            button.snp.updateConstraints { make in
                make.centerX.equalTo(monthBtnStackView.snp.centerX).offset(offset)
            }
        }
        
        //2.更新底部阴影
        print("更新底部阴影")
        blurEffectView.removeFromSuperview()
        layoutBottomGradientView()
        
        //3.刷新flowlayout
        reloadCollectionViewData(forRow: -1, animated: true)
        
        //4.更新搜索栏
        if isFilterMode{
            popover.dismiss()
        }
        
        //5.更新日历视图：需要重新创建lwCalendar实例，否则日期cell布局错乱
        lwCalendar.removeFromSuperview()
        lwCalendar = LWCalendar(frame: .zero)
        lwCalendar.dataSource = self
        lwCalendar.delegate = self
        self.monthBtnStackView.addSubview(lwCalendar)
        lwCalendar.alpha = isShowingCalendar ? 1 : 0
        lwCalendar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kTopViewHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
        }
    }
}

//MARK:  -ipad分屏
extension monthVC{
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        globalConstantsManager.shared.currentTraitCollection = newCollection
        //2:regular,1:compact
        print("newCollection.verticalSizeClass:\(newCollection.verticalSizeClass.rawValue),newCollection.horizontalSizeClass:\(newCollection.horizontalSizeClass.rawValue)")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("monthVC viewWillTransition")
        globalConstantsManager.shared.appSize = size
        self.onContainerSizeChanged()
    }

}

//MARK:  -动画
extension monthVC:UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = editorAnimator()
        animator.animationType = .present
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = editorAnimator()
        animator.animationType = .dismiss
        return animator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return editorBlurPresentVC(presentedViewController: presented, presenting: presenting)
    }
}

// MARK:  响应通知
extension monthVC{
    
}
