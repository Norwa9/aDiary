//
//  monthVC+calendar.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/16.
//

import UIKit
import FSCalendar
import Popover
import MJRefresh
import RealmSwift

extension monthVC{
    func initCalendarUI(){
        //MARK:-日历
        //configure FSCalendar
        let calendarPedding:CGFloat = 10
        let calendarWidth = monthBtnStackView.frame.width - 2 * calendarPedding
        let calendar = FSCalendar(frame: CGRect(
                                    x: (monthBtnStackView.frame.width - calendarWidth) / 2,
                                    y: monthBtnStackView.frame.maxY,
                                    width: calendarWidth,
                                    height: calendarHeight))
//        calendar.layer.borderWidth = 1
        calendarHeightOriginFrame = calendar.frame
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.scrollEnabled = true
        calendar.firstWeekday = 2
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .clear
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .black
        calendar.headerHeight = 0//移除年月份栏
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 17)
        calendar.appearance.titleFont = UIFont.appCalendarCellTitleFont()
        calendar.appearance.weekdayTextColor = UIColor.colorWithHex(hexColor: 0x90969B)//石岩灰
        calendar.appearance.eventSelectionColor = .black
        calendar.appearance.selectionColor = #colorLiteral(red: 0.2, green: 0.231372549, blue: 0.2509803922, alpha: 1)
        calendar.appearance.titleSelectionColor = APP_GREEN_COLOR()
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -5)
        calendar.appearance.eventDefaultColor = .black
        calendar.appearance.headerDateFormat = "yyyy年M月"
        calendar.locale = Locale(identifier: "zh_CN")//设置周次为中文
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase//设置为一、二···
        calendar.placeholderType = .none//仅显示当月日期cell
        self.calendar = calendar
        calendar.alpha = 0
        self.monthBtnStackView.addSubview(calendar)
    }
}


//MARK:-FSCalendar数据源和代理
extension monthVC:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,ExtendedFSCalendarDelegate{
    //使用DIY cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        
        cell.initUI(forDate: date)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
//        print("FSCalendar willDisplay cell")
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    //点击cell
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        //1、显示绿色圆环
        self.configureVisibleCells()
        
//        //2、如果选中未来日期，摇晃cell
//        if date.compare(Date()) == .orderedDescending{
//            cell?.shake()
//            return
//        }
        
        //2、进入日记
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: date)
        let predicate = NSPredicate(format: "date = %@", dateString)
        if let selectedDiary = LWRealmManager.shared.query(predicate: predicate).first{
            
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
    
// MARK: - FSCalendar自定义外观
    private func configureVisibleCells() {
        //参考自FSCalendar作者的demo
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DIYCalendarCell)
        
        //设置cell的选取视图：圆环
        if calendar.selectedDates.contains(date){
            cell.selectionType = .single
        }else{
            cell.selectionType = .none
        }
        
    }
    
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//    }
    
    func didEndDecelerating(calendar: FSCalendar) {
        /*
         calendarCurrentPageDidChange存在问题：页面是willchange时调用而不是didchange时调用
         为此使用网友提供的ExtendedFSCalendarDelegate。
         通过didEndDecelerating来真正实现page didchange时调用
        */
        //获取当前页面月份
        print("didEndDecelerating(calendar: FSCalendar)")
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: calendar.currentPage))!
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: calendar.currentPage))!

        selectedYear = year
        selectedMonth = month
    }
    
    //event dot数量
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        formatter.dateFormat = "yyyy年M月d日"
        let localDB = LWRealmManager.shared.localDatabase

        for diary in localDB{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.content.count != 0{
                return 1
            }
        }
        return 0
    }
    //事件点默认颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        formatter.dateFormat = "yyyy年M月d日"
        let localDB = LWRealmManager.shared.localDatabase
        for diary in localDB{
            //如果有内容
            if diary.date == formatter.string(from: date) && diary.islike{
                return [.yellow]
            }
        }
        return [.black]
    }
    //事件点选取状态的颜色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [APP_GREEN_COLOR()]
    }
    
    
}

//来源：
extension FSCalendar: UIScrollViewDelegate {
public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
(delegate as? ExtendedFSCalendarDelegate)?.didEndDecelerating(calendar: self)
}
}

protocol ExtendedFSCalendarDelegate: FSCalendarDelegate {
func didEndDecelerating(calendar: FSCalendar)
}

extension ExtendedFSCalendarDelegate {
func didEndDecelerating(calendar: FSCalendar) { }
}
