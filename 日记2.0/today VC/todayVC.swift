//
//  todayVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit


let kTextViewPeddingX:CGFloat = 0
class todayVC: UIViewController{
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
        
        subpagesView.models = [model]
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemGray6
        
        //topView
        topView = TopView()
        
        //subpagesView
        subpagesView = LWSubpagesView()
        
        
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
        return
        print("toggleTopView")
        isShowingTopView.toggle()
        let topViewHeight = topView.bounds.height
        subpagesView.snp.updateConstraints { (update) in
            if isShowingTopView{
                update.top.equalTo(topView.snp.bottom).offset(5)
            }else{
                update.top.equalTo(topView.snp.bottom).offset(-topViewHeight - 5)
            }
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
            self.view.backgroundColor = self.isShowingTopView ? .systemGray6 : .systemBackground
            self.view.layoutIfNeeded()
        } completion: { (_) in

        }
    }
}


//MARK:-UIGestureRecognizerDelegate
extension todayVC:UIGestureRecognizerDelegate,UIScrollViewDelegate{
    @objc func handlePanGesture(_ gesture:UIPanGestureRecognizer){
        if draggingDownToDismiss == false && subpagesView.textView.contentSize.height > view.bounds.height{
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
        return 
        let y = scrollView.contentOffset.y
        //print(y)
        
        if subpagesView.textView.isFirstResponder {return}
        
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


