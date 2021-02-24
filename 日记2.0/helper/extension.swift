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


let weekDaysCN:Dictionary<String,String> = ["Mon":"星期一","Tue":"星期二","Wed":"星期三","Thu":"星期四","Fri":"星期五","Sat":"星期六","Sun":"星期天"]

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

func getWeekDayFromDateString(string:String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    if let date = formatter.date(from: string){
        formatter.dateFormat = "EEE"
        return weekDaysCN[formatter.string(from: date)]!
    }else{
        return "Unknow"
    }
}

func getTodayDate()->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    let date = Date()
    return formatter.string(from: date)
}

func getExactCurrentTime()->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "-H:mm-"
    return formatter.string(from: Date())
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



func initalSelectedDiary()->diaryInfo{
    let dateTodayString = getTodayDate()
    //如果今天已经有日记，返回今天日记；没有的话就创建一个空的模板
    if let diary = DataContainerSingleton.sharedDataContainer.diaryDict[dateTodayString]{
        return diary
    }else{
        return diaryInfo(dateString: dateTodayString)
    }
}


