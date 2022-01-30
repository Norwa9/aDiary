//
//  LWCalendar.swift
//  日记2.0
//
//  Created by yy on 2021/7/22.
//

import UIKit
import FSCalendar

class LWCalendar: FSCalendar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        self.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        self.appearance.headerDateFormat = "yyyy年M月"
        self.firstWeekday = 2
        self.locale = Locale(identifier: "zh_CN")//设置周次为中文
        self.placeholderType = .none//仅显示当月日期cell
        self.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        
        self.scrollEnabled = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .clear
        self.appearance.todayColor = .clear
        self.appearance.titleTodayColor = .label
        self.appearance.titleSelectionColor = .label
        self.appearance.titleDefaultColor = .label
        self.headerHeight = 0//移除年月份栏
        self.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 17)
        self.appearance.titleFont = UIFont.appCalendarCellTitleFont()
        self.appearance.weekdayTextColor = UIColor.colorWithHex(hexColor: 0x90969B)//石岩灰
        self.appearance.eventSelectionColor = .black
        //event dot
        self.appearance.eventOffset = CGPoint(x: 0, y: -5)
        self.appearance.selectionColor = eventDotDynamicColor
        self.appearance.eventDefaultColor = eventDotDynamicColor
        
    }
    
    
}
//MARK:-DataSource
extension monthVC:FSCalendarDataSource{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        
        cell.initUI(forDate: date)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
}

//MARK:-Delegate
extension monthVC:FSCalendarDelegate{
    //点击cell
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        //1、显示绿色圆环
        //self.configureVisibleCells()
        
        //1.bounce
        cell?.bounceAnimation(usingSpringWithDamping: 0.8, scaleFactor: 0.9)
        
        //2、进入日记
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        let predicate = NSPredicate(format: "date = %@", dateString)
        if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
            presentEditorVC(withViewModel: selectedDiary)
        }else{
            //3,补日记
            let popoverAlert = customAlertView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 75)))
            popoverAlert.dateString = dateString
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

// MARK: - FSCalendar自定义外观
extension monthVC:FSCalendarDelegateAppearance{
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        lwCalendar.visibleCells().forEach { (cell) in
            let date = lwCalendar.date(for: cell)
            let position = lwCalendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        if lwCalendar.selectedDates.contains(date){
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
}


extension monthVC:ExtendedFSCalendarDelegate{
    func didEndDecelerating(calendar: FSCalendar) {
        /*
         calendarCurrentPageDidChange存在问题：页面是willchange时调用而不是didchange时调用
         为此使用网友提供的ExtendedFSCalendarDelegate。
         通过didEndDecelerating来真正实现page didchange时调用
        */
        //获取当前页面月份
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!

        selectedYear = year
        selectedMonth = month
        updateUI()
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
