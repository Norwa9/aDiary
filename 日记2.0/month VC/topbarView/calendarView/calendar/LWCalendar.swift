//
//  LWCalendar.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import FSCalendar
import Popover

class LWCalendar: FSCalendar {
    var viewModel:monthViewModel
    let monthVC = UIApplication.getMonthVC()
    let popover:Popover = LWPopoverHelper.shared.getCalendarPopover()
    
    init(viewModel:monthViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.dataSource = self
        self.delegate = self
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        self.scrollEnabled = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .clear
        
        // weakday
        self.appearance.headerDateFormat = "yyyy年M月"
        self.firstWeekday = 2
        self.locale = Locale(identifier: "zh_CN")//设置周次为中文
        self.placeholderType = .none//仅显示当月日期cell
        self.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        self.headerHeight = 0//移除年月份栏
        self.appearance.weekdayFont = userDefaultManager.calendarFont(ofSize: 17)
        self.appearance.weekdayTextColor = UIColor.colorWithHex(hexColor: 0x90969B)//石岩灰
        
        // title
        self.appearance.todayColor = .clear
        self.appearance.titleTodayColor = .label
        self.appearance.titleSelectionColor = .label
        self.appearance.titleDefaultColor = .label
        self.appearance.titleFont = userDefaultManager.calendarFont(ofSize: 20)
        
        // subtitle
        self.appearance.subtitleDefaultColor = .secondaryLabel
        self.appearance.subtitleSelectionColor = .secondaryLabel
        self.appearance.subtitleTodayColor = .secondaryLabel
        
        //event dot
        self.appearance.eventSelectionColor = .black
        self.appearance.eventOffset = CGPoint(x: 0, y: -2)
        self.appearance.selectionColor = eventDotDynamicColor
        self.appearance.eventDefaultColor = eventDotDynamicColor
        
        self.reloadData()
    }
    
    
}
//MARK:   -DataSource
extension LWCalendar:FSCalendarDataSource{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        //print(date)
        cell.initUI(forDate: date)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
}

//MARK: -Delegate
extension LWCalendar:FSCalendarDelegate{
    //点击cell
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        //1、显示绿色圆环
        //self.configureVisibleCells()
        
        //1.bounce
        cell?.showBounceAnimation {}
        
        //2、进入日记
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        let predicate = NSPredicate(format: "date = %@", dateString)
        if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
            monthVC?.presentEditorVC(withViewModel: selectedDiary)
        }else{
            //3,补日记
            let popoverAlert = customAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
            popoverAlert.dateString = dateString
            popoverAlert.delegate = self
            popover.show(popoverAlert, fromView: cell!)
        }
        
    }
    
    //取消点击cell
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //自定义选取动画
//        print("didDeselect")
//        self.configureVisibleCells()
    }
}

// MARK:   - FSCalendar自定义外观
extension LWCalendar:FSCalendarDelegateAppearance{
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        self.visibleCells().forEach { (cell) in
            let date = self.date(for: cell)
            let position = self.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        if self.selectedDates.contains(date){
            cell.selectionType = .single
        }else{
            cell.selectionType = .none
        }
        
    }
    
    //event dot数量
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let diary = LWRealmManager.shared.queryFor(date: date).first{
            let todoModels = diary.lwTodoModels
            let uncheckedTodoModels = todoModels.filter { model in
                model.state == 0
            }
            return uncheckedTodoModels.count
        }else{
            return 0
        }
    }
    
    //事件点默认颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return nil
    }
    
    //事件点选取状态的颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return nil
    }
    
    // 农历
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if userDefaultManager.showLunar{
            return LWLunarFormatter.shared.stringFromDate(date: date)
        }else{
            return nil
        }
        
    }
}


extension LWCalendar:ExtendedFSCalendarDelegate{
    func didEndDecelerating(calendar: FSCalendar) {
        /*
         calendarCurrentPageDidChange存在问题：页面是willchange时调用而不是didchange时调用
         为此使用网友提供的ExtendedFSCalendarDelegate。
         通过didEndDecelerating来真正实现page didchange时调用
        */
        //获取当前页面月份
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!

        viewModel.selectedYear = year
        viewModel.selectedMonth = month
        monthVC?.updateUIForDateChange()
    }
}

extension LWCalendar: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        ///scrollViewDidEndDecelerating时调用delegate的didEndDecelerating方法
        ///在这里，delegate就是montgVC
        (delegate as? ExtendedFSCalendarDelegate)?.didEndDecelerating(calendar: self)
    }
}

protocol ExtendedFSCalendarDelegate: FSCalendarDelegate {
    func didEndDecelerating(calendar: FSCalendar)
}

extension ExtendedFSCalendarDelegate {
    func didEndDecelerating(calendar: FSCalendar) { }
}
