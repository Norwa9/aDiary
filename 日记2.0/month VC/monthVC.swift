//
//  monthVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import FSCalendar

class monthVC: UIViewController {
    var viewModel:monthViewModel!
    
    var topbarView:LWTopbarView!
    
    var dateView: LWDateView!
    
    var diaryListView:LWDiaryListView!
    
    var floatButton:LWFloatButton!
    
    var blurEffectView:UIVisualEffectView!
    
    //编辑器
    var editorVC:todayVC!
    
    //MARK: -生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = monthViewModel(monthVC: self)
        
        initUI()
        setupConstraint()
        loadData()
        
    }
    
    private func loadData(){
        // 预加载todayVC
        editorVC = todayVC()
        let _ = editorVC.view
        editorVC.modalPresentationStyle = .custom
        editorVC.transitioningDelegate = self
        
        // 加载子视图UI
        topbarView.updateUIForDateChange()
        diaryListView.updateUIForDateChange()
        floatButton.updateUIForDateChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // WhatsNew
        if let vc = WhatsNewHelper.getWhatsNewViewController(){
            self.present(vc, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                vc.dismiss(animated: true, completion: nil)
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
        
        // topbarView
        topbarView = LWTopbarView(viewModel: viewModel)
        
        diaryListView = LWDiaryListView(viewModel: viewModel)
        
        floatButton = LWFloatButton(viewModel: viewModel)
        
        blurEffectView = LWBottomGradientViewHelper.shared.getBottomGradientView()
        
        self.view.addSubview(diaryListView)
        self.view.addSubview(topbarView)
        self.view.addSubview(floatButton)
        self.view.addSubview(blurEffectView)
        
    }
    
    
    //MARK: -auto layout
    private func setupConstraint(){
        topbarView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(LWTopbarView.kTopBarViewHeight)
        }
    
        diaryListView.snp.makeConstraints { make in
            make.top.equalTo(topbarView.snp.bottom).offset(4)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        floatButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 100, height: 40))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
    }
    
    //MARK:  顶部4大按钮触发事件
    func topBarButtonTapped(button: topbarButton){
        switch button.tag {
        case 0: // 显示日期视图
            switchDateView()
        case 1: // 切换单双列展示
            layoutParasManager.shared.switchLayoutMode()
            button.switchLayoutModeIcon()
            diaryListView.reloadCollectionViewData(forRow: -1,animated: true)// 刷新数据源，同时伴有动画效果
        case 2: // 进入设置界面
            let settingVC = LWSettingViewController()
            present(settingVC, animated: true, completion: nil)
        case 3: // 进入搜索视图
            switchFilterView()
        default:
            break
        }
    }
    
    /// 展示日记
    func presentEditorVC(withViewModel viewModel:diaryInfo){
        guard self.presentedViewController == nil else { return }
        guard editorVC.isBeingPresented == false else { return }
        editorVC.model = viewModel
        self.present(editorVC, animated: true, completion: nil)
    }
    
    
    
    
    /// 显示或隐藏FloatButton
    func toggleFloatButton(toShow:Bool){
        self.floatButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(toShow ? -100 : 100)
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        } completion: { _ in}
    }
}

// MARK: topbarView相关
extension monthVC{
    /// 切换搜索视图
    public func switchFilterView(){
        if viewModel.isShowingDateView{
            // 如果展示日历，先收回日历
            self.switchDateView()
        }
        viewModel.isFilterMode.toggle()
        let isFilterMode = viewModel.isFilterMode
        // 1. 更新top bar : label、topbarButton、dateView
        // 2. 更新list view
        // 3. 更新floatButton

        // 更新topbarView
        self.topbarView.updateUIForFilterMode()
        // 更新 list view
        self.diaryListView.updateUIForFilterMode()
        // 更新 floatButton 的显示/隐藏
        self.toggleFloatButton(toShow: !isFilterMode)
    }

    
    /// 切换日期视图
    public func switchDateView(){
        viewModel.isShowingDateView.toggle()
        // 只需要更新topbarView相关的视图
        self.topbarView.updateUIForDateView()
    }
}

//MARK: reload重新加载相关
extension monthVC{
    /// selectedYear或者selectedMonth更新后，需要更新子视图界面
    func updateUIForDateChange(){
        // 更新数据源
        viewModel.loadDataSource(year: viewModel.selectedYear, month: viewModel.selectedMonth)
        
        // 更新子视图UI
        topbarView.updateUIForDateChange()
        diaryListView.updateUIForDateChange()
        floatButton.updateUIForDateChange()
    }
    
    /// 刷新主页的collectionView与calendar
    public func reloadCollectionViewAndDateView(forRow row:Int = -1){
        if viewModel.isFilterMode{
            viewModel.loadFilteredDataSource()
            diaryListView.updateDataSource()
        }else{
            viewModel.loadDataSource(year: viewModel.selectedYear, month: viewModel.selectedMonth)
            diaryListView.updateDataSource(forRow: row)
            topbarView.dateView.reloadData()
        }
    }
    
    /// 更新搜索结果
    public func reloadAfterFilter(diaryNum:Int,wordCount:Int){
        //更新collectionView
        diaryListView.updateDataSource()
        //更新topbar label
        topbarView.updateUIAfterFilter(diaryNum: diaryNum, wordCount: wordCount)
    }
}


//MARK:  -屏幕旋转
extension monthVC{
    @objc private func onContainerSizeChanged(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            print("!= ipad")
            return
        }

        // 1. 更新 month Buttons 布局
        // 2. 重新添加calendar
        self.topbarView.dateView.onContainerSizeChanged()
        
        // 3. 更新底部阴影
        self.blurEffectView.removeFromSuperview()
        self.blurEffectView = LWBottomGradientViewHelper.shared.getBottomGradientView()
        self.view.addSubview(blurEffectView)
        
        // 4. 刷新flowlayout
        self.diaryListView.reloadCollectionViewData(forRow: -1, animated: true)
        
        // 5. 更新搜索栏
        self.topbarView.filterView.popover.dismiss()
        
       
    }
}




//MARK:  -切换深色模式监听事件
extension monthVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // 深色模式下不显示毛玻璃层
        if UITraitCollection.current.userInterfaceStyle == .dark{
            blurEffectView.alpha = 0
        }else{
            blurEffectView.alpha = 1
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

