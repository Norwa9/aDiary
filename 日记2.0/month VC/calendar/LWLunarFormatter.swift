//
//  LWLunarFormatter.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/15.
//

import Foundation

class LWLunarFormatter{
    static let shared = LWLunarFormatter()
    private var chineseCalendar:Calendar
    private var formatter:DateFormatter
    private var lunarDays:[String]
    private var lunarMonths:[String]
    
    init() {
        self.chineseCalendar = Calendar(identifier: .chinese)
        self.formatter = DateFormatter()
        self.formatter.calendar = self.chineseCalendar
        self.formatter.dateFormat = "M"
        self.lunarDays = ["初二","初三","初四","初五","初六","初七","初八","初九","初十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十","廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"]
        self.lunarMonths = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
    }
    
    func stringFromDate(date: Date) -> String{
        let day = self.chineseCalendar.component(.day, from: date)
        if day != 1{
            return self.lunarDays[day - 2]
        }
        
        // 月份的第一天
        var monthString = self.formatter.string(from: date)
        if self.chineseCalendar.veryShortMonthSymbols.contains(monthString){
            if let m = Int(monthString){
                return self.lunarMonths[m - 1]
            }
            
        }
        
        // 闰月
        let month = self.chineseCalendar.component(.month, from: date)
        monthString = "闰\(self.lunarMonths[month - 1])"
        return monthString
    }
    
    
}
