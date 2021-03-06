//
//  extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/1.
//

import Foundation
import UIKit
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
    case hour
    case mintue
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
    case .hour:
        return dateComponents.hour!
    case .mintue:
        return dateComponents.minute!
    }
}

///获取今天的日期或者指定日期的weekday
func GetWeekday(dateString:String?) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    let date:Date
    if let dateString = dateString{
        date = formatter.date(from: dateString)!
    }else{
        date = Date()
    }
    formatter.dateFormat = "EEE"
    let string =  formatter.string(from: date)
    return string
}

func GetTodayDate()->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    let date = Date()
    return formatter.string(from: date)
}

func DateToCNString(date:Date)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    return formatter.string(from: date)
}

/// 将日期转换为widget点击事件Link的url（不能包含中文）
func DateCNToUrl(pageDateCN:String) ->String? {
    var dateString = ""
    var pageNumString = ""
    if let splitIndex = pageDateCN.firstIndex(of: "-"){
        // 页号
        let indexAfter = pageDateCN.index(after: splitIndex)
        pageNumString = String(pageDateCN[indexAfter..<pageDateCN.endIndex])
        pageNumString = "-" + pageNumString
        // 日期
        let indexBefore = pageDateCN.index(before: splitIndex)
        dateString = String(pageDateCN[pageDateCN.startIndex..<indexBefore])
    }else{
        dateString = pageDateCN
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    if let date = formatter.date(from: dateString){
        formatter.dateFormat = "yyyy/M/d"
        let dateUrlString = formatter.string(from: date)
        let res = dateUrlString + pageNumString
        return res
    }else{
        return nil
    }
    
}

/// 将widget点击事件Link的url转换回日期格式
func UrlToDateCN(pageDateUrl:String) -> String{
    var dateUrl = ""
    var pageNumString = ""
    if let splitIndex = pageDateUrl.firstIndex(of: "-"){
        // 页号
        let indexAfter = pageDateUrl.index(after: splitIndex)
        pageNumString = String(pageDateUrl[indexAfter..<pageDateUrl.endIndex])
        pageNumString = "-" + pageNumString
        // 日期
        dateUrl = String(pageDateUrl[pageDateUrl.startIndex..<splitIndex])
    }else{
        dateUrl = pageDateUrl
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/M/d"
    let date = formatter.date(from: dateUrl)!
    formatter.dateFormat = "yyyy年M月d日"
    let dateString = formatter.string(from: date)
    let res = dateString + pageNumString
    return res
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


/// 转换时间格式：将1/60s为单位的值转换为分:秒:小数
/// count 以1/60为基本单位
func getConvertedTime(count:CGFloat?)->String{
    if let time = count{
        let count = Int(time)
        let minute = count / 3600
        let second = count / 60
        let remainder = count % 60
        let minute_s = String(format: "%02d", minute)
        let second_s = String(format: "%02d", second)
        let remainder_s = String(format: "%02d", remainder)
        return "\(minute_s):\(second_s):\(remainder_s)"
    }
    return "null"
}

