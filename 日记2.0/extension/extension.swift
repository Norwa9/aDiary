//
//  extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import Foundation
import UIKit

var diaryDict = [String:[String]]()

enum moodTypes:String,CaseIterable,Codable{
    case happy = "happy"
    case calm = "calm"
    case unhappy = "unhappy"
}

enum sortStyle:Int {
    case dateDescending
    case dateAscending
    case wordDescending
    case wordAscending
    case like
}


let weekDaysCN:Dictionary<String,String> = ["Mon":"周一","Tue":"周二","Wed":"周三","Thu":"周四","Fri":"周五","Sat":"周六","Sun":"周日"]

enum dateInfo {
    case day
    case month
    case year
    case weekDay
}
func getDateComponent(for date:Date,for key:dateInfo) -> Int{
    
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents(in: TimeZone.current, from: date)
    switch key {
    case .day:
        return  dateComponents.day!
    case .month:
        return dateComponents.month!
    case .year:
        return dateComponents.year!
    case .weekDay:
        return dateComponents.weekday! - 1
    }
}

func getTodayDate()->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    let date = Date()
    return formatter.string(from: date)
}




func howManyDaysInThisMonth(year:Int,month:Int)->Int{
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
        return 31 ;
    }
    if((month == 4) || (month == 6) || (month == 9) || (month == 11)){
        return 30;
    }
    if((year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3))
    {
    return 28;
    }
    if(year % 400 == 0){
        return 29;
    }
    if(year % 100 == 0){
        return 28;
    }
    return 29;
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}



extension Date{
    //获取当前星期几
    func getWeekday()->String{
        let weekDays = [NSNull.init(),"周日","周一","周二","周三","周四","周五","周六"] as [Any]
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let timeZone = NSTimeZone.init(name: "Asia/Shanghai")
        calendar?.timeZone = timeZone! as TimeZone
        let calendarUnit = NSCalendar.Unit.weekday
        let theComponents = calendar?.components(calendarUnit, from: self)
        return weekDays[(theComponents?.weekday)!] as! String
    }
    
    func getWeekday(dateString:String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        let date = formatter.date(from: dateString)
        formatter.dateFormat = "EEE"
        let string =  formatter.string(from: date!)
        #if targetEnvironment(simulator)
            return weekDaysCN[string]!
        #endif
        return string
    }
}

