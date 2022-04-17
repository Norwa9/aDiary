//
//  LWCanendarView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/4/17.
//

import Foundation
import UIKit
import FSCalendar

class LWCanendarView:UIView{
    weak var delegate:monthVC!
    // month buttons
    var monthBtnStackView:UIView!
    let kmonthBtnStackViewHeight:CGFloat = 40.0
    var monthButtons = [monthButton]()
    
    // calendars
    var isShowingCalendar:Bool = false
    var lwCalendar:LWCalendar!
    let kCalendarHeight:CGFloat = 300
    
    init() {
        super.init(frame: .zero)
        initUI()
        setCons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.backgroundColor = .systemBackground
        
        //monthBtnStackView
        monthBtnStackView = UIView()
        monthBtnStackView.layer.cornerRadius = 10
        monthBtnStackView.backgroundColor = monthBtnStackViewDynamicColor
        monthBtnStackView.setupShadow()
        for i in 0..<12{
            let button = monthButton(frame: .zero)
            button.monthVC = delegate
            button.monthLabel.text = "\(i+1)"
            button.tag = i+1
            button.addTarget(self, action: #selector(monthDidTap(sender:)), for: .touchUpInside)
            monthButtons.append(button)
            monthBtnStackView.addSubview(button)
        }
        
        //calendar
        lwCalendar = LWCalendar(frame: .zero)
        lwCalendar.dataSource = delegate
        lwCalendar.delegate = delegate
        lwCalendar.alpha = 0
        
        
        
        self.addSubview(monthBtnStackView)
        self.addSubview(lwCalendar)
    }
    
    func setCons(){
        monthBtnStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kmonthBtnStackViewHeight)
        }
        lwCalendar.snp.makeConstraints { make in
            make.top.equalTo(self.monthBtnStackView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
        }
        
        // month buttons的布局
        let kButtonDiameter = monthButton.monthButtonDiameter // 按钮的高度
        let insetY:CGFloat = (kmonthBtnStackViewHeight - kButtonDiameter) / 2
        if UIDevice.current.userInterfaceIdiom == .phone{
            // iPhone上使用frame 布局monthButtons
            delegate.view.layoutIfNeeded()//获取到真实的frame
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
    
    @objc func monthDidTap(sender:monthButton){
        let tappedMonth = sender.tag
        if tappedMonth == delegate.selectedMonth{
            
        }else{
            delegate.selectedMonth = tappedMonth
            delegate.updateUI()
        }
    }
    
    //MARK: calendar warpped
    /// 跳转日历的月份月面
    func setCurrentPage(_ currentPage: Date, animated: Bool){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        lwCalendar?.setCurrentPage(formatter.date(from: "\(delegate.selectedYear!)-\(delegate.selectedMonth!)")!, animated: true)
    }
    
    /// 重新读取日历数据源
    func reloadData(){
        lwCalendar?.reloadData()
    }
    
    /// 更新日历视图：需要重新创建lwCalendar实例，否则日期cell布局错乱
    func reloadCalendarView(){
        
        lwCalendar.removeFromSuperview()
        lwCalendar = LWCalendar(frame: .zero)
        lwCalendar.dataSource = delegate
        lwCalendar.delegate = delegate
        self.addSubview(lwCalendar)
        lwCalendar.alpha = isShowingCalendar ? 1 : 0
        lwCalendar.snp.makeConstraints { (make) in
            make.top.equalTo(self.monthBtnStackView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(kCalendarHeight)
        }
    }
}
