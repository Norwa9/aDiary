//
//  LWTodoSettingView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/26.
//

import Foundation
import UIKit

class LWTodoSettingViewController:UIViewController{
    /// delegate
    var todoView:LWTodoView
    var viewModel:LWTodoViewModel
    
    var containerView:UIView!
    /// 标题：提醒
    var remindTitle:UILabel!
    /// 提醒开关
    var remindSwitch:UISwitch!
    /// 日期选取
    var datePicker:UIDatePicker!
    /// 无提醒时文案
    var noRemindPromptLabel:UILabel!
    /// 标题：备注
    var noteTitle:UILabel!
    /// 备注输入框
    var noteTextView:UITextView!
    
    /// 删除按钮
    var deleteButton:UIButton!
    
    /// 完成按钮
    var doneButton:UIButton!
    
    var settingViewY:CGFloat?
    
    init(viewModel:LWTodoViewModel,todoView:LWTodoView) {
        self.viewModel = viewModel
        self.todoView = todoView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingViewY = self.view.frame.origin.y
        initUI()
    }
    
    private func initUI(){
        self.view.backgroundColor = .systemBackground
        self.view.layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.backgroundColor =  .systemBackground
        containerView.layer.cornerRadius = 10
        
        remindTitle = UILabel()
        remindTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        remindTitle.text = "提醒"
        
        remindSwitch = UISwitch()
        remindSwitch.isOn = viewModel.needRemind
        remindSwitch.addTarget(self, action: #selector(remindSwitchChanged(_:)), for: .valueChanged)
        
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.timeZone = .current
        datePicker.layer.cornerRadius = 5
        datePicker.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        noRemindPromptLabel = UILabel()
        noRemindPromptLabel.text = "暂未设置提醒时间"
        noRemindPromptLabel.textAlignment = .center
        noRemindPromptLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        loadDatePicker()
        
        noteTitle = UILabel()
        noteTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        noteTitle.text = "备注"
        
        noteTextView = UITextView()
        noteTextView.delegate = self
        noteTextView.backgroundColor = .secondarySystemBackground
        noteTextView.layer.cornerRadius = 10
        noteTextView.text = viewModel.note
        noteTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        deleteButton = UIButton()
        let attrDeleteTitle = NSAttributedString(string: "删除").addingAttributes([
            .foregroundColor : UIColor.red,
            .font : UIFont.systemFont(ofSize: 18, weight: .bold)
        ])
        deleteButton.setAttributedTitle(attrDeleteTitle, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        
        doneButton = UIButton()
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 10
        let attrDoneTitle = NSAttributedString(string: "完成").addingAttributes([
            .foregroundColor : UIColor.white,
            .font : UIFont.systemFont(ofSize: 18, weight: .bold)
        ])
        doneButton.setAttributedTitle(attrDoneTitle, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        
        
        self.view.addSubview(containerView)
        containerView.addSubview(remindTitle)
        containerView.addSubview(remindSwitch)
        containerView.addSubview(noRemindPromptLabel)
        containerView.addSubview(datePicker)
        containerView.addSubview(noteTitle)
        containerView.addSubview(noteTextView)
        containerView.addSubview(deleteButton)
        containerView.addSubview(doneButton)
        
        self.setConstraints()
        
        
        
    }
    
    private func loadDatePicker(){
        if viewModel.needRemind{
            datePicker.date = viewModel.remindDate
            print("datePicker.alpha = 1")
            datePicker.alpha = 1
            noRemindPromptLabel.alpha = 0
        }else{
            print("datePicker.alpha = 0")
            datePicker.alpha = 0
            noRemindPromptLabel.alpha = 1
        }
    }
    
    private func setConstraints(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        remindTitle.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(18)
            make.right.equalTo(self.remindSwitch.snp.left).offset(-2)
        }
        
        remindSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(remindTitle)
        }
        remindSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        datePicker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.remindTitle.snp.bottom).offset(10)
        }
        
        noRemindPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(self.remindTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
        
        noteTitle.snp.makeConstraints { make in
            make.left.equalTo(self.remindTitle)
            make.top.equalTo(self.datePicker.snp.bottom).offset(10)
            make.top.equalTo(self.noRemindPromptLabel.snp.bottom).offset(10)
        }
        
        noteTextView.snp.makeConstraints { make in
            make.left.equalTo(self.remindTitle)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(self.noteTitle.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            // make.height.lessThanOrEqualTo(140)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.left.equalTo(self.remindTitle)
            make.top.equalTo(self.noteTextView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        doneButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.centerY.equalTo(self.deleteButton.snp.centerY)
            make.right.equalTo(self.noteTextView)
        }
        
        
        
    }
    @objc func remindSwitchChanged(_ sender:UISwitch){
        if sender.isOn{
            // 0.检查订阅情况
            let purchased = proEditionMaskHelper.shared.checkPurchaseAndPrompt {
                // 未订阅后的动作
                DispatchQueue.main.async {
                    sender.setOn(false, animated: true)
                    self.viewModel.needRemind = false
                    self.loadDatePicker()
                }
            }
            // 1. 未订阅，提醒+关闭开关
            if !purchased{
                print("未订阅，return")
                return
            }
            
            print("已订阅，继续下一步检查通知权限")
            // 2. 已订阅，检查通知是否开启
            LWNotificationHelper.shared.checkNotificationAuthorization {
                // requestdeniedAction
                // 关掉开关
                DispatchQueue.main.async {
                    sender.setOn(false, animated: true)
                    self.viewModel.needRemind = false
                    self.loadDatePicker()
                }
            } requestGrantedAction: {
                // requestGrantedAction
                // 打开开关
                DispatchQueue.main.async {
                    self.viewModel.needRemind = true
                    self.loadDatePicker()
                }
                
            }
        }else{
            self.viewModel.needRemind = false
            self.loadDatePicker()
        }
    }
    
    @objc func deleteButtonTapped(_ sender:UIButton){
        remindSwitch.setOn(false, animated: true) // 防止saveTodo中又注册通知
        viewModel.needRemind = false // 防止saveTodo中又注册通知
        viewModel.deleteTodoView()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveAndReloadView()
    }
    
    /// 保存当前界面的设置结果
    func saveAndReloadView(){
        viewModel.needRemind = remindSwitch.isOn
        viewModel.note = noteTextView.text
        if remindSwitch.isOn{
            viewModel.remindDate = datePicker.date
        }
        viewModel.reloadTodoView(todoView: todoView)
    }
    
    
    
}
extension LWTodoSettingViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        let purchased = proEditionMaskHelper.shared.checkPurchaseAndPrompt {
            // 未订阅后动作
            DispatchQueue.main.async {
                textView.resignFirstResponder()
            }
        }
        if !purchased{
            return
        }
        // 调整inset
        adjustTodoSettingView()
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.note = textView.text
        adjustTodoSettingView()
    }
    
    func adjustTodoSettingView(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut]) {
            if let orginY = self.settingViewY,let bottomInset = globalConstantsManager.shared.bottomInset{
                print("orginY:\(orginY)")
                print("bottomInset:\(bottomInset)")
                print("self.view.frame:\(self.view.frame)")
                if self.noteTextView.isFirstResponder{
                    
                    self.view.frame.origin.y = orginY + 40 // 40 toolbar的高度
                }else{
                    self.view.frame.origin.y = orginY + bottomInset
                }
            }
        } completion: { _ in
            
        }
    }
}

extension LWTodoSettingViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return cardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
