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
    private func initUI(){
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
            if viewModel.hasExtroInfo{ // has extro
                make.top.equalToSuperview()
            }else{ // no extro label
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        self.extroInfoLabel.snp.makeConstraints { make in
            if viewModel.hasExtroInfo{
                print(viewModel.hasExtroInfo)
                make.top.equalTo(self.contentTextView.snp.bottom).offset(2)
                make.left.right.equalTo(self.contentTextView)
                make.bottom.equalToSuperview().offset(-2)
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
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if viewModel.state == 0{
            viewModel.state = 1
        }else{
            viewModel.state = 0
        }
        
        // 先保存当前内容
        viewModel.content = self.contentTextView.text
        // 再reload view
        loadStateButton()
        loadContentTextField()
        if viewModel.todoViewStyle == 1{
            // 保存在monthCell上施加的变动到diaryinfo，然后刷新monthCell就可以更新视图
            viewModel.saveAndupdateTodoListView()
        }
        viewModel.saveTodo()
        
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
        
        // 3.更新textView视图
        viewModel.reloadTodoView(todoView: self)
        
        // 4.更新selectRange
        viewModel.lwTextView?.resignFirstResponder()
    }
    
    /// 计算正确的bounds，以便刷新todoView
    func calToDoViewBounds() -> CGRect{
        let newHeight:CGFloat
        if viewModel.hasExtroInfo{
            newHeight = max(viewModel.todoFont.lineHeight, contentTextView.contentSize.height) + viewModel.extroInfoLabelFont.lineHeight + 2 * 2 // padding : 2x2
            print("hasExtroInfo, newHeight:\(newHeight)")
        }else{
            newHeight = max(viewModel.todoFont.lineHeight, contentTextView.contentSize.height)
        }
        print("newHeight:\(newHeight)")
        let newBounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: newHeight)
        return newBounds
    }
    
    
}
