//
//  ScalableImageView.swift
//  BSTextDemo
//
//  Created by 罗威 on 2021/8/24.
//  Copyright © 2021 GeekBruce. All rights reserved.
//

import Foundation
import UIKit
import PopMenu
import JXPhotoBrowser

class ScalableImageView:UIView, UIGestureRecognizerDelegate{
    private var imageView:UIImageView!
    private var dot: UIView?
    private var doneView:UIImageView?
    var editViewBtn:UIButton!
    var startFrame:CGRect!
    weak var delegate:LWTextView?
    let popManager = LWPopManager()
    
    var viewModel:ScalableImageViewModel
    
    init(viewModel:ScalableImageViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.bounds)
        
        initUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.layer.cornerRadius = 5
        
        //1.imageView
        imageView = UIImageView()
        imageView.image = viewModel.image
        imageView.contentMode = viewModel.contentMode
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.addBorder(width: 1, color: .systemGray4)
        self.addSubview(imageView)
        imageView.frame = self.bounds
        
        //2.dotView
        if viewModel.isEditing{
             addDotView()
        }
        
        //3.tap gesture
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        self.addGestureRecognizer(tapGes)
        
        // 4. editView
        addEditView()
        
        startFrame = self.frame
    }
    
    /// 弹出编辑框
    func addEditView(){
        let editViewSize = CGSize(width: 30.0, height: 30.0)
        let padding:CGFloat = 5.0
        editViewBtn = UIButton(frame: CGRect(x: self.width - padding - editViewSize.width, y: padding, width: editViewSize.width, height: editViewSize.height))
        editViewBtn.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        editViewBtn.tintColor = .black
        editViewBtn.addTarget(self, action: #selector(presentEditActionMenu(_:)), for: .touchUpInside)
        editViewBtn.backgroundColor = LWColorConstatnsManager.imageEditBtnBGColor
        editViewBtn.roundCorners(.allCorners, radius: 5)
        self.addSubview(editViewBtn)
    }
    
    
    /// 修改大小的圆点View
    func addDotView(){
        weak var wlabel = self
        
        //1.添加dot view
        dot = newDotView()
        if viewModel.paraStyle == imageRightParagraphStyle{
            dot?.center = CGPoint(x: 0, y: self.height)
        }else{
            dot?.center = CGPoint(x: self.width, y: self.height)
        }
        dot?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        if let dot = dot {
            doneView = UIImageView(image: #imageLiteral(resourceName: "tagSelected"))
            dot.addSubview(doneView!)
            doneView!.snp.makeConstraints { make in
                make.edges.equalTo(dot)
            }
            self.addSubview(dot)
            
            if viewModel.shouldShowDoneView{
                print("should show")
                showDoneView()
            }else{
                doneView?.alpha = 0
            }
        }
        
        
        let gesture = BSGestureRecognizer()
        gesture.targetView = self
        gesture.action = { [self] gesture, state in
            if state == .began{
                print(" state == .began")
            }else if state == BSGestureRecognizerState.moved {
                UIApplication.getTodayVC()?.isAdjustScalableImageView = true
                let x = gesture!.currentPoint.x
                let y = gesture!.currentPoint.y
                var newWidth:CGFloat
                if viewModel.paraStyle == imageRightParagraphStyle{
                    newWidth = startFrame.width - x
                    dot?.center.x = x
                }else{
                    newWidth = x
                }
                let width  = newWidth
                let height = y
                print(x,y,width,height)
                wlabel?.width = width < 30 ? 30 : width
                wlabel?.height = height < 30 ? 30 : height
            }else if state == .ended{
                UIApplication.getTodayVC()?.isAdjustScalableImageView = false
                
                print("state == .ended")
                if gesture!.startPoint.equalTo(gesture!.currentPoint){
                    //完成编辑
                    self.doneEditing(){
                        self.delegate?.reloadScableImage(endView: self)
                        self.delegate?.textViewController?.save()
                    }
                }else{
                    //继续编辑
                    self.viewModel.shouldShowDoneView = true
                    self.delegate?.reloadScableImage(endView: self)
                }
            }
        }
        gesture.delegate = self
        dot?.addGestureRecognizer(gesture)
        
        //2.添加view的边框
        self.addBorder()
    }
    
    private func newDotView() -> UIView? {
        let view = UIView()
        view.size = CGSize(width: 50, height: 50)
        
        let dot = UIView()
        dot.size = CGSize(width: 30, height: 30)
        dot.backgroundColor = .systemGray5
        dot.clipsToBounds = true
        dot.layer.cornerRadius = dot.height / 2
        dot.center = CGPoint(x: view.width / 2, y: view.height / 2)
        view.addSubview(dot)
        
        return view
    }
    
    private func addBorder(){
        self.layer.borderWidth = 2
        self.layer.borderColor = APP_GREEN_COLOR().cgColor
    }
    
    private func removeBorder(){
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    
}

//MARK:-action target
extension ScalableImageView{
    @objc func presentEditActionMenu(_ sender: UIButton){
//        if let view = sender.view as? ScalableImageView{
//            if view == self{
//                popManager.PresentPopMenu(sourceView: view)
//            }
//        }
        popManager.PresentPopMenu(scImage: self, sourceView: sender)
    }
    
    @objc func imageTapped(_ sender: UIGestureRecognizer!) {
        let view = self
        guard let textView = view.delegate else {return}
        let browser = JXPhotoBrowser()
        let img = view.viewModel.image
        let attachmentFrame = textView.layoutManager.boundingRect(forGlyphRange: NSRange(location: view.viewModel.location, length: 1), in: textView.textContainer)
        //图片浏览器数据源
        //将黑色背景替换为玻璃模糊
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        browser.maskView = blurView
        
        browser.numberOfItems = { 1 }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.image = img
        }
        
        //显示图片与收回图片的转场动画
        browser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, toView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
            //toView:大图的imageView
            //fromView:textView里的图片附件view
            let fromView = UIImageView(image: img)
            fromView.contentMode = .scaleAspectFit
            fromView.clipsToBounds = true
            //y + 8 是为了解决奇怪的偏移量bug
            let fromFrame = CGRect(x: attachmentFrame.origin.x, y: attachmentFrame.origin.y + 8, width: attachmentFrame.size.width, height: attachmentFrame.size.height)
            let thumbnailFrame = textView.convert(fromFrame, to: toView)
            return (fromView,thumbnailFrame)
        })
        browser.show()
        
    }
    
    func showDoneView(){
        self.doneView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.2) {
            self.doneView?.transform = .identity
        } completion: { (_) in
            
        }

    }
    
    ///结束大小编辑
    func doneEditing(completion:(()->())? = nil){
        print("done editing")
        viewModel.shouldShowDoneView = false
        viewModel.isEditing = false
        UIView.animate(withDuration: 0.2) {
            self.dot?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.dot?.alpha = 0
            self.removeBorder()
        } completion: { (_) in
            self.dot?.removeFromSuperview()
            completion?()
        }
    }
    
    
    
}

extension ScalableImageView{
    /// 子视图超出本视图的部分也能接收事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    
        if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 ){
            return nil
        }
        let resultView  = super.hitTest(point, with: event)
        if resultView != nil {
            //print("type(of: resultView):\(type(of: resultView))")
            return resultView
        } else {
            for subView in self.subviews.reversed() {
                // 这里根据层级的不同，需要遍历的次数可能不同，看需求来写，我写的例子是一层的
                let convertPoint : CGPoint = subView.convert(point, from: self)
                let hitView = subView.hitTest(convertPoint, with: event)
                if (hitView != nil) {
                    return hitView
                }
            }
        }
        return nil
    }
}
