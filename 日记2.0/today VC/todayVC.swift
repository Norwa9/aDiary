//
//  todayVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit


let kTextViewPeddingX:CGFloat = 0
class todayVC: UIViewController{
    ///引入多页的概念后，传来的model可能是pages的主页面，也可能是子页面
    var model:diaryInfo! {
        didSet{
            setModel()
        }
    }
    
    ///顶部容器视图
    var topView:TopView!
    var isShowingTopView:Bool = true
    
    //多页面视图
    var subpagesView:LWSubpagesView!

    //下滑手势
    var draggingDownToDismiss = false
    var dismissPanGesture:UIPanGestureRecognizer!
    var interactStartPoint:CGPoint?
    
    //MARK:-生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        //设备方向
        notificationCenter.addObserver(self, selector: #selector(onDeviceDirectionChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.initUI()
        self.setupConstraints()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //更新monthVC的UI
        let monthVC = UIApplication.getMonthVC()
        if model.month == monthVC.selectedMonth{
            //仅当日记对应的月份和当前monthvc显示的月份一致时，才需要刷新collectionView
            monthVC.reloadCollectionViewData(forRow: model.row)
            monthVC.lwCalendar?.reloadData()
        }
    }
    
    //MARK:-setModel
    func setModel(){
        updateUI()
    }
    
    func updateUI(){
        //调用setter，更新UI
        topView.model = model
        topView.layoutIfNeeded()
        
        //引入多页的概念后，传来的model可能是pages的主页面，也可能是子页面
        let trueDate = model.trueDate//表示查询当日所有页面
        let models = LWRealmManager.shared.queryAllPages(ofDate: trueDate)
        subpagesView.currentPageIndex = model.indexOfPage
        subpagesView.models = models
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemGray6
        
        //topView
        topView = TopView()
        
        //subpagesView
        subpagesView = LWSubpagesView()
        subpagesView.todayVC  = self
        
        
        //panGesture
        dismissPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        dismissPanGesture.maximumNumberOfTouches = 1
        dismissPanGesture.delegate = self
        //view.addGestureRecognizer(dismissPanGesture)
        
        self.view.addSubview(topView)
        self.view.addSubview(subpagesView)
        
    }
    
    //MARK:-auto layout
    private func setupConstraints(){
        topView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.equalTo(subpagesView)
        }
        
        subpagesView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.equalTo(self.view).offset(kTextViewPeddingX)
            make.right.equalTo(self.view).offset(-kTextViewPeddingX)
            make.bottom.equalTo(self.view)
        }
    }
}

//MARK:-emojiView
extension todayVC{
    ///显示/隐藏表情盘
    func toggleTopView(){
        print("toggleTopView")
        //return
        isShowingTopView.toggle()
        let inset = topView.bounds.height - topView.dateLable.bounds.height
        subpagesView.snp.updateConstraints { (update) in
            if isShowingTopView{
                update.top.equalTo(topView.snp.bottom).offset(5)
            }else{
                update.top.equalTo(topView.snp.bottom).offset(-inset + 2)
            }
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            self.view.backgroundColor = self.isShowingTopView ? .systemGray6 : .systemBackground
            self.subpagesView.segmentedView.backgroundColor = self.isShowingTopView ? .systemGray6 : .systemBackground
            self.topView.tagsView.alpha = self.isShowingTopView ? 1 : 0
            self.topView.emojiView.alpha = self.isShowingTopView ? 1 : 0
            self.view.layoutIfNeeded()
        } completion: { (_) in

        }
    }
    
    func updateTopViewHeight(){
        if isShowingTopView{
            self.view.layoutIfNeeded()//平滑过渡tags的高度变化
        }else{
            //如果希望隐藏topView，左右切换需要计算topView的高度
            let curInset = topView.bounds.height - topView.dateLable.bounds.height
            subpagesView.snp.updateConstraints { (update) in
                update.top.equalTo(topView.snp.bottom).offset(-curInset + 2)
            }
            subpagesView.pagingView.layoutSubviews()//不加的话textView底部会有空白条，不知道为啥
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
}


//MARK:-UIGestureRecognizerDelegate
extension todayVC:UIGestureRecognizerDelegate,UIScrollViewDelegate{
    @objc func handlePanGesture(_ gesture:UIPanGestureRecognizer){
        if draggingDownToDismiss == false && subpagesView.mainTableView.contentSize.height > view.bounds.height{
            return
        }
        //初始触摸点
        let startingPoint: CGPoint
        if let p = interactStartPoint{
            startingPoint = p
        }else{
            startingPoint = gesture.location(in: nil)
            interactStartPoint = startingPoint
        }
        
        //当前触摸点
        let currentLocation = gesture.location(in: nil)
        
        
        //触摸进度
        let progress = (currentLocation.y - startingPoint.y) / 100
        print("PanGesture progress:\(progress)")
        
        if progress >= 1.0{
            interactStartPoint = nil
            draggingDownToDismiss = false
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    //解决下拉dismiss和scrollview的冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //下拉dismiss
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
//        print(y)
        
        if subpagesView.mainTableView.isFirstResponder {return}
        
        //解决下拉dismiss和scrollview的冲突
        if y < 0 {
            scrollView.contentOffset = .zero
            draggingDownToDismiss = true//仅在scrollview到顶时，才启用下拉dismiss
        }
    }
    
}

//MARK:-旋转屏幕
extension todayVC{
    @objc private func onDeviceDirectionChange(){
        guard UIDevice.current.userInterfaceIdiom == .pad else{
            return
        }
        //只响应横竖的变化
        guard UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isLandscape else{
            return
        }
        
        //2.关闭表情盘（如果存在的话）
        topView.emojiView.popover.dismiss()
        
    }
}


