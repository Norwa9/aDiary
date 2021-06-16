//
//  shareVC.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/25.
//

import UIKit

class shareVC: UIViewController {
    let Kradius:CGFloat = 10
    var scrollView:shareScrollView!
    
    private lazy var dismissPanGesture: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer()
        ges.maximumNumberOfTouches = 1
        ges.addTarget(self, action: #selector(handleDismissPan(gesture:)))
        ges.delegate = self
        return ges
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 5, width: 30, height: 30)
        btn.setImage(#imageLiteral(resourceName: "save"), for: .normal)
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
    
    var dismissClosure: (()->())?
    var interactiveStartingPoint: CGPoint? = nil//the point when start to interactive
    var draggingDownToDismiss = false
    
    var diary:diaryInfo!
    var snapshot:UIImage!
    
    init(diary:diaryInfo) {
        self.diary = diary
        super.init(nibName: nil, bundle: nil)
        self.setupTranstion()
    }
    
    private func setupTranstion() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subView in view.subviews {
            if let subView = subView as? UIScrollView {
                subView.delegate = self
            }
        }
        
        view.addGestureRecognizer(dismissPanGesture)
        
        setupUI()
        setupConstraints()

    }
    
    func setupUI(){
        //scroll View
        scrollView = shareScrollView(frame: .zero, snapshot: snapshot,diary: diary)
        scrollView.layer.cornerRadius = Kradius
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        //view
        view.backgroundColor = .white
        view.clipsToBounds = true//裁剪过长的scrollview
        view.layer.cornerRadius = Kradius
        
        view.addSubview(scrollView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
    }
    
    func setupConstraints(){
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //此时调用才能获得正确的view.bounds.width
        saveBtn.frame.origin.x = view.bounds.width - saveBtn.bounds.width - 5
//        print(saveBtn.frame.origin.x)
//        print(view.bounds)
    }
    
    @objc private func handleDismissPan(gesture: UIPanGestureRecognizer) {
        if !draggingDownToDismiss{
            return
        }
        
        let startingPoint: CGPoint
        
        //设置初始触摸点
        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            startingPoint = gesture.location(in: nil)//nil表示window
            interactiveStartingPoint = startingPoint
        }

        let currentLocation = gesture.location(in: nil)
        
        var progress = (currentLocation.y - startingPoint.y) / 100
        
        //prevent viewController bigger when scrolling up
        if currentLocation.y <= startingPoint.y {
            progress = 0
        }
        
        if progress >= 1.0 {
            dismiss(animated: true, completion: nil)
            dismissClosure?()
//            stopDismissPanGesture(gesture)
            draggingDownToDismiss = false
            interactiveStartingPoint = nil
            return
        }

        let targetShrinkScale: CGFloat = 0.86
        let currentScale: CGFloat = 1 - (1 - targetShrinkScale) * progress
        
        switch gesture.state {
        case .began,.changed:
            gesture.view?.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
            gesture.view?.layer.cornerRadius = Kradius * (1 + progress)
        case .cancelled,.ended:
            stopDismissPanGesture(gesture)
        default:
            break
        }
    }
    
    //MARK:-targets
    //当下拉Offset超过100或取消下拉手势时，执行此方法
    private func stopDismissPanGesture(_ gesture: UIPanGestureRecognizer) {
        draggingDownToDismiss = false
        interactiveStartingPoint = nil
        
        UIView.animate(withDuration: 0.2) {
            gesture.view?.transform = CGAffineTransform.identity
        }
    }
    
    @objc func closeAction(){
        dismiss(animated: true, completion: nil)
        dismissClosure?()
    }
    
    @objc func saveAction(){
        let shareImg = self.scrollView.scrollViewScreenshot!
        print("shareImg.size:\(shareImg.size)")
        UIImageWriteToSavedPhotosAlbum(shareImg, nil, nil, nil)
        let ac = UIAlertController(title: "保存成功", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        ac.view.setupShadow()
        self.present(ac, animated: true, completion: nil)
    }
    
    
}

//MARK:-UIViewControllerTransitioningDelegate
extension shareVC:UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PopAnimator()
        animator.animationType = .present
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PopAnimator()
        animator.animationType = .dismiss
        return animator
    }
    
    //使用presentationController来添加高斯模糊的效果
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return blurPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK:-UIGestureRecognizerDelegate
extension shareVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
//MARK:-UIScrollViewDelegate
extension shareVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
//        print(y)
        //解决下拉dismiss和scrollview的冲突
        if y < 0 {
            scrollView.contentOffset = .zero
            draggingDownToDismiss = true
        }
 
    }
}

