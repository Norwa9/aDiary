//
//  monthViewModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/1.
//

import Foundation

class monthViewModel{
    var monthVC:monthVC
    var selectedYear:Int
    var currentYear:Int
    var selectedMonth:Int
    var currentMonth:Int
    var selectedDay:Int
    var currentDay:Int
    var isCurrentMonth:Bool{
        get{
            return self.currentMonth == self.selectedMonth
        }
    }
    
    var dataSource:[diaryInfo]
    
    // collection View
    var performingLayoutSwitch:Bool = false // 当前是否在转换瀑布流视图
    
    // filter view
    var isFilterMode:Bool = false
    var filteredDiaries:[diaryInfo] = []
    
    // date view
    var isShowingDateView:Bool = false
    
    
    init(monthVC:monthVC){
        self.monthVC = monthVC
        self.selectedYear = getDateComponent(for: Date(), for: .year)
        self.currentYear = self.selectedYear
        self.selectedMonth = getDateComponent(for: Date(), for: .month)
        self.currentMonth = self.selectedMonth
        self.selectedDay = getDateComponent(for: Date(), for: .day)
        self.currentDay = self.selectedDay
        self.dataSource = diariesForMonth(forYear: selectedYear, forMonth: selectedMonth)
    }
    
    /// 读取某年某月的日记，或读取全部日记
    /// year=0,month=0时表示读取全部日记
    public func loadDataSource(year:Int,month:Int,forRow row:Int = -1){
        let dataSource = diariesForMonth(forYear: year, forMonth: month)
        if row != -1 && self.dataSource.count > row{
            // 仅需更新dataSource里的第 row 行数据
            self.dataSource[row] = dataSource[row]
            return
        }
        self.dataSource = dataSource
        
    }
    
    /// 读取选取的条件的日记，
    /// 返回满足要求的日记的数量和字数
    /// 副作用：更新dataSource与filteredDiaries
    public func loadFilteredDataSource()->(Int,Int){
        let res = filterHelper.shared.filter()
        let filtered = res.0
        let num = res.1
        let wordCount = res.2
        self.filteredDiaries = filtered
        self.dataSource = Array(filtered.prefix(20))
        print("search results:\(self.filteredDiaries.count)")
        
        return (num,wordCount)
    }
    
    
}
