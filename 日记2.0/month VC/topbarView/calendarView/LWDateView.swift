//
//  LWDateView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/4/17.
//

import Foundation
import UIKit
import FSCalendar

class LWDateView:UIView{
    var viewModel:monthViewModel
    let monthVC = UIApplication.getMonthVC()
    
    // month buttons
    var monthBtnStackView:UIView!
    let kmonthBtnStackViewHeight:CGFloat = 40.0
    let kmonthBtnStackViewPadding:CGFloat = 5.0 // 左右距离父视图的padding
    var monthButtons = [monthButton]()
    
    // calendars
    var isShowingCalendar:Bool = false
    var lwCalendar:LWCalendar!
    let kCalendarHeight:CGFloat = 300
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI(){
        self.backgroundColor = .systemBackground
        
        //monthBtnStackView
        monthBtnStackView = UIView()
        monthBtnStackView.layer.cornerRadius = 10
        monthBtnStackView.backgroundColor = monthBtnStackViewDynamicColor
        monthBtnStackView.setupShadow()
        for i in 0..<12{
            let button = monthButton(frame: .zero)
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidTap(sender:)), for: .touchUpInside)
            monthButtons.append(button)
            monthBtnStackView.addSubview(button)
        }
        
        //calendar
        lwCalendar = LWCalendar(viewModel: viewModel)
        
        self.addSubview(monthBtnStackView)
        self.monthBtnStackView.addSubview(lwCalendar)
    }
    
    private func setCons(){
        // 1.
        monthBtnStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kmonthBtnStackViewPadding)
            make.right.equalToSuperview().offset(-kmonthBtnStackViewPadding)
//            make.height.equalTo(kmonthBtnStackViewHeight)
            make.bottom.equalToSuperview()
        }
        // 2.
        lwCalendar.snp.makeConstraints { make in
            //初始时calendar高度被挤压为0
            make.top.equalToSuperview().offset(kmonthBtnStackViewHeight)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
        }
        
        // 3. month buttons的约束手动计算
        let kButtonDiameter = monthButton.monthButtonDiameter // 按钮的高度
        let insetY:CGFloat = (kmonthBtnStackViewHeight - kButtonDiameter) / 2
        let stackViewWidth = globalConstantsManager.shared.kScreenWidth - 2 * kmonthBtnStackViewPadding
        let padding:CGFloat = (stackViewWidth - 12.0 * kButtonDiameter) / 13.0
        if UIDevice.current.userInterfaceIdiom == .phone{
            // iPhone上使用frame 布局monthButtons
            for i in 0..<12{
                let x = kButtonDiameter * CGFloat(i) + padding * CGFloat(i+1)
                let y = insetY
                monthButtons[i].frame = CGRect(x: x, y: y, width: kButtonDiameter, height: kButtonDiameter)
            }
        }else{
            // iPad上使用autoLayout
//            let padding:CGFloat = (globalConstantsManager.shared.kScreenWidth - 12 * kButtonDiameter) / 13
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
    
    @objc func monthDidTap(sender:monthButton){
        let tappedMonth = sender.tag
        if tappedMonth == viewModel.selectedMonth{
            
        }else{
            viewModel.selectedMonth = tappedMonth
            monthVC?.updateUIForDateChange()
        }
    }
    
    
    
    /// 重新读取日历数据源
    public func reloadData(){
        lwCalendar?.reloadData()
    }
    
    public func updateUIForDateChange(){
        // 1. 更新calendar
        let selectedYear = viewModel.selectedYear
        let selectedMonth = viewModel.selectedMonth
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let date = formatter.date(from: "\(selectedYear)-\(selectedMonth)")!
        self.setCurrentPage(date, animated: true)
        
        // 2. 更新monthButtons的点亮状态
        for button in monthButtons{
            if button.hasSelected{
                button.animateBackgroundColor()
            }
            
            if button.tag == selectedMonth{
                button.animateBackgroundColor()
            }
        }
    }
    
    /// 封装：跳转日历的月份月面
    private func setCurrentPage(_ currentPage: Date, animated: Bool){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        lwCalendar?.setCurrentPage(formatter.date(from: "\(viewModel.selectedYear)-\(viewModel.selectedMonth)")!, animated: true)
    }
    
    /// 显示/关闭日期视图的UI切换
     func updateUIForToggle(toShow:Bool){
         if toShow{
             
         }else{
            
         }
//        let newHeihgt = isShowingCalendar ? (kTopViewHeight + kCalendarHeight) : kTopViewHeight
//
//        topView.snp.updateConstraints { (update) in
//            update.height.equalTo(newHeihgt)
//        }
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
//            self.lwCalendar.alpha = self.isShowingCalendar ? 1 : 0
//            self.view.layoutIfNeeded()
//        } completion: { (_) in
//
//        }
//
//         UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut) {
//             self.monthBtnStackView.alpha = self.isFilterMode ? 0:1
//         } completion: { (_) in}
        
    }
    
    /// 屏幕旋转
    /// 1. 重新布局monthBtnStackView
    /// 2. 重新添加lwCalendar到视图层级
    public func onContainerSizeChanged(){
        let isShowingDateView = viewModel.isShowingDateView
        
        // 1. 重新布局monthBtnStackView
        let kButtonDiameter = monthButton.monthButtonDiameter
        let stackViewWidth = globalConstantsManager.shared.kScreenWidth - 2 * kmonthBtnStackViewPadding
        let padding:CGFloat = (stackViewWidth - 12.0 * kButtonDiameter) / 13.0
        for i in 0..<12{
            let button = monthButtons[i]
            let offset:CGFloat = (CGFloat(i) - 5.5) * kButtonDiameter + (CGFloat(i) - 5.5) * padding
            button.snp.updateConstraints { make in
                make.centerX.equalTo(monthBtnStackView.snp.centerX).offset(offset)
            }
        }
        
        // 2. 更新日历视图：需要重新创建lwCalendar实例，否则日期cell布局错乱
        lwCalendar.removeFromSuperview()
        lwCalendar = LWCalendar(viewModel: viewModel)
        monthBtnStackView.addSubview(lwCalendar)
        lwCalendar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kmonthBtnStackViewHeight)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
        }
    }
}
