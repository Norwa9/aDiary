//
//  LWTodoView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/24.
//

import Foundation
import UIKit
import SnapKit
import PopMenu
import Popover

class LWTodoView:UIView{
    /// 底部容器视图
    var containerView:UIView!
    /// 完成按钮
    var stateButton:UIButton!
    /// 待办内容文本
    var contentTextView:UITextView!
    /// 更多设置按钮
    var moreButton:UIButton!
    /// 附加信息文本
    var extroInfoLabel:UILabel!
    
    var viewModel:LWTodoViewModel

    
    init(viewModel:LWTodoViewModel) {
        self.viewModel = viewModel
        super.init(frame: viewModel.bounds)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    func initUI(){
        // containerView
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
//        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.layer.cornerRadius = 5
        containerView.setupShadow(opacity: 0.1, radius: 0.5, offset: .zero, color: .black)
        
        // stateButton
        stateButton = UIButton()
        stateButton.addTarget(self, action: #selector(stateButtonTapped(_:)), for: .touchUpInside)
        self.loadStateButton()
        
        // contentLabel
        contentTextView = UITextView()
        contentTextView.delegate = self
        contentTextView.showsVerticalScrollIndicator = false
        contentTextView.textContainer.lineFragmentPadding = 0 //内容缩进为0（去除左右内边距）
        contentTextView.textContainerInset = .zero //文本边距设为0（去除上下内边距）
        // contentTextView.setDebugBorder()
        contentTextView.font = viewModel.todoFont // 使用用户自定义字体
        if viewModel.todoViewStyle == 1{
            contentTextView.textContainer.maximumNumberOfLines = 1
            contentTextView.isEditable = false
        }
        self.loadContentTextField()
        
        // extroInfoLabel
        extroInfoLabel = UILabel()
        self.loadExtroInfoLabel()
        
        // moreButton
        moreButton = UIButton()
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        
        self.addSubview(containerView)
        containerView.addSubview(stateButton)
        containerView.addSubview(contentTextView)
        containerView.addSubview(extroInfoLabel)
        containerView.addSubview(moreButton)
        
        self.setCons()
        layoutIfNeeded() // 立即更新布局。否则LWTodoView.asImage()不能产生图像，这是因为UIView在被添加到视图层级之时，才会进行布局。
        self.bounds = calToDoViewBounds() // 装填内容后，计算正确高度
    }
    
    //MARK: Constraint
    private func setCons(){
        self.snp.makeConstraints { make in
            if viewModel.todoViewStyle == 1{
                // 这里不设置，由TodoListCell设置LWTodoView的约束
            }else if viewModel.todoViewStyle == 0{
                make.width.equalTo(viewModel.bounds.width)
                make.height.equalTo(viewModel.bounds.height)
            }
        }
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.stateButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            let fontHeight = viewModel.todoFont.lineHeight * 1.4
            make.size.equalTo(CGSize(width: fontHeight, height: fontHeight))
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if viewModel.todoViewStyle == 0{
                make.right.equalToSuperview().offset(0)
                let fontHeight = viewModel.todoFont.lineHeight
                make.size.equalTo(CGSize(width: fontHeight, height: fontHeight))
            }else if viewModel.todoViewStyle == 1{
                make.width.equalTo(0)
                make.right.equalToSuperview().offset(-2)
            }
            
        }
        
        self.contentTextView.snp.makeConstraints { make in
            make.left.equalTo(self.stateButton.snp.right)
            make.right.equalTo(self.moreButton.snp.left)
            let padding = globalConstantsManager.shared.todoViewInternalPadding
            if viewModel.hasExtroInfo{ // has extro
                make.top.equalToSuperview().offset(padding)
            }else{ // no extro label
                make.top.equalToSuperview().offset(padding)
                make.bottom.equalToSuperview().offset(-padding)
                make.centerY.equalToSuperview()
            }
        }
        
        self.extroInfoLabel.snp.makeConstraints { make in
            let padding = globalConstantsManager.shared.todoViewInternalPadding
            if viewModel.hasExtroInfo{
                print(viewModel.hasExtroInfo)
                make.top.equalTo(self.contentTextView.snp.bottom).offset(padding)
                make.left.right.equalTo(self.contentTextView)
                make.bottom.equalToSuperview().offset(-padding)
            }
        }
        
        
    }
    
    private func loadStateButton(){
        let stateImg = viewModel.getStateIcon()
        stateButton.setImage(stateImg, for: .normal)
    }
    
    private func loadContentTextField(){
        if let content = viewModel.getTodoContent(){
            self.contentTextView.attributedText = content
        }else{
            // self.contentTextView.attributedPlaceholder = viewModel.getAttributedPlaceHolder()
        }
    }
    
    private func loadExtroInfoLabel(){
        self.extroInfoLabel.attributedText = viewModel.getExtroInfoText()
    }
    
    //MARK: button
    @objc func stateButtonTapped(_ sender:UIButton){
        // 1. 震动
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // 2. 刷新todo按钮
        viewModel.toggleTodoState()
        loadStateButton()
        
        // 3. 刷新todo内容颜色和完成划线
        viewModel.content = self.contentTextView.text
        loadContentTextField()
        
        // 4. 刷新附加信息
        loadExtroInfoLabel()
        
        // 5. 刷新monthCell
        if viewModel.todoViewStyle == 1{
            // 保存在monthCell上施加的变动到diaryinfo，然后刷新monthCell就可以更新视图
            viewModel.saveAndupdateTodoListView()
        }
        
        // 6. 持久化更改
        viewModel.reloadTodoView(todoView: self)
        
    }
    
    @objc func moreButtonTapped(_ sender:UIButton){
        contentTextView.resignFirstResponder()
        viewModel.lwTextView?.resignFirstResponder()
        
        let todoSetVC = LWTodoSettingViewController(viewModel: viewModel,todoView: self)
        todoSetVC.transitioningDelegate = todoSetVC
        todoSetVC.modalPresentationStyle = .custom//模态
        UIApplication.getTodayVC()?.present(todoSetVC, animated: true, completion: nil)
    }
    
    
}

//MARK: UITextViewDelegate
extension LWTodoView:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.lwTextView?.textViewController?.isTextViewEditing = true // 防止退出手势冲突
        viewModel.lwTextView?.textViewController?.keyBoardToolsBar.reloadTextViewToolBar(type: 1)
        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderWidth = 1
        }
        viewModel.adjustTextViewInset()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            
            // textView.resignFirstResponder()
            
            // 另起一行新建todo或者回到lwTextView
            viewModel.dealWithEnterTapped(todoTextView: textView)
            
            return false // 不回应换行
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("todo end editing")
        viewModel.lwTextView?.textViewController?.isTextViewEditing = false // 防止退出手势冲突
        // 1.
        if let todoText = self.contentTextView.text{
            viewModel.content = todoText
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.layer.borderWidth = 0
        }, completion: { _ in
            
        })
        // 3.更新textView视图
        self.viewModel.reloadTodoView(todoView: self)
        
        // 4.更新selectRange
        self.viewModel.lwTextView?.resignFirstResponder()

    }
    
    /// 计算正确的bounds，以便刷新todoView
    func calToDoViewBounds() -> CGRect{
        //定义一个constrainSize值用于计算textview的
        let constrainSize=CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        let textViewSize = contentTextView.sizeThatFits(constrainSize)
        let extroInfoLabelSize = extroInfoLabel.sizeThatFits(constrainSize)
        let padding = globalConstantsManager.shared.todoViewInternalPadding
        
        let newHeight:CGFloat
        if viewModel.hasExtroInfo{
//            newHeight = max(viewModel.todoFont.lineHeight, contentTextView.contentSize.height) + viewModel.extroInfoLabelFont.lineHeight + 2 * 2 // padding : 2x2
            newHeight = contentTextView.contentSize.height + extroInfoLabelSize.height + 3 * padding
        }else{
            newHeight = contentTextView.contentSize.height + 2 * padding
        }
         // print("newHeight:\(newHeight),textViewHeight:\(textViewSize.height),extroInfoLabelHeight:\(extroInfoLabelSize.height)")
        let newBounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: newHeight)
        return newBounds
    }
    
    
}
