//
//  globalFuncs.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/5.
//

import Foundation
import UIKit

//MARK:-导入用户引导
func LoadIntroText(){
    if !userDefaultManager.hasInitialized{
        userDefaultManager.hasInitialized = true
        let date = getTodayDate()
        let introDiary = diaryInfo(dateString: date)
        if let levelFileURL = Bundle.main.url(forResource: "introduction", withExtension: "txt") {
            if let textContents = try? String(contentsOf: levelFileURL) {
                introDiary.content = textContents
                DataContainerSingleton.sharedDataContainer.diaryDict[date] = introDiary
            }
        }
    }
}

//MARK:-导入DayGram日记
func parseDayGramText(text:String){
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    //得到解析后的日记
    let diaryDict = txt2String(string: text)
    var count = 0
    for (key,content) in diaryDict{
        let dateString = formatter.string(from: key)
        
        guard DataContainerSingleton.sharedDataContainer.diaryDict[dateString] == nil else{
            continue
        }
        
        DataContainerSingleton.sharedDataContainer.diaryDict[dateString] = diaryInfo(dateString: dateString)
        DataContainerSingleton.sharedDataContainer.diaryDict[dateString]?.content = content
        count += 1
        print("\(dateString)已创建，第\(count)篇")
        
    }
}

//MARK:-从String解析出每一篇日记的时间以及内容
func txt2String(string:String) -> [Date:String]{
    let formatter = DateFormatter()
    #if targetEnvironment(simulator)
    formatter.dateFormat = "MMMM d EEEE yyyy"
    #else
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMMM d EEEE yyyy"
    #endif
    var count = 0
    var date = Date()
    var content = ""
    var dateDict = [Date:String]()
    let lines = string.components(separatedBy: "\n")
    for line in lines{
        //开始遍历新日记
        if line.contains("**"){
            if count != 0{//排除第一篇日记的情况
                dateDict[date] = content//表示已经扫描完一篇日记，存储它
                content.removeAll()
            }
            count += 1
            let beg = line.index(line.startIndex, offsetBy: 3)
            let end = line.index(line.endIndex, offsetBy: -3)
            date = formatter.date(from: String(line[beg..<end]))!
            continue
        }
        if line == ""{
            continue
        }
        content.append(line+"\n")
    }
    return dateDict
}

//MARK:-获取指定日期的日记
func diariesForMonth(forYear:Int,forMonth:Int)->[diaryInfo?]{
    let diaryDict = DataContainerSingleton.sharedDataContainer.diaryDict
    var tempDiaries = [diaryInfo?]()
    
    //1，返回所有日记
    if forYear == 0 && forMonth == 0{
        //0,0是特例：表示返回所有日记
        for (_,diary) in diaryDict{
            tempDiaries.append(diary)
        }
        
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy年M月d日"
        //返回日期降序的所有日记
        return tempDiaries.sorted { (d1, d2) -> Bool in
            if let date1 = dateFomatter.date(from: d1!.date) ,let date2 = dateFomatter.date(from: d2!.date){
                if date1.compare(date2) ==  .orderedAscending{
                    return true
                }
            }
            return false
        }
    }
    
    //2，返回指定年/月日记
    for i in 1...howManyDaysInThisMonth(year: forYear, month: forMonth){
        let timeString = "\(forYear)年\(forMonth)月\(i)日"
        let diary = DataContainerSingleton.sharedDataContainer.diaryDict[timeString]//字典元素不存在将返回nil
        tempDiaries.append(diary)
    }
    return tempDiaries
}

//MARK:-获取符合筛选条件的所有日记
func filterDiary()->[diaryInfo]{
    let keywords = filterModel.shared.searchText
    let selectedMood = filterModel.shared.selectedMood
    let selectedTags = filterModel.shared.selectedTags
    let sortStyle = filterModel.shared.selectedSortstyle
    
    let allDiary = DataContainerSingleton.sharedDataContainer.diaryDict.values
    var resultDiaries = [diaryInfo]()
    
    
    //1筛选：关键字
    if keywords != ""{
        resultDiaries = allDiary.filter { (item: diaryInfo) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.content.range(of: keywords, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
    }else{
        //如果没有关键词，返回所有日记
        print("无关键词")
        for diary in allDiary{
            resultDiaries.append(diary)
        }
    }
    
    //2筛选：心情和标签
    if let mood = selectedMood{
        resultDiaries = resultDiaries.filter{ (item: diaryInfo) -> Bool in
            return item.mood == mood.rawValue
        }
    }
    
    //3筛选标签
    resultDiaries = resultDiaries.filter{ (item: diaryInfo) -> Bool in
        return containSubArr(selectedTags: selectedTags, diaryTags: item.tags)
    }

    //4、筛选：排序方式
    let dateFomatter = DateFormatter()
    dateFomatter.dateFormat = "yyyy年M月d日"
    switch sortStyle {
        case .dateDescending:
            return resultDiaries.sorted { (d1, d2) -> Bool in
                if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
                    if date1.compare(date2) ==  .orderedDescending{
                        return true
                    }
                }
                return false
            }
        case .dateAscending:
            return resultDiaries.sorted { (d1, d2) -> Bool in
                if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
                    if date1.compare(date2) ==  .orderedAscending{
                        return true
                    }
                }
                return false
            }
        case .wordDescending:
            return resultDiaries.sorted(by:{$0.content.count > $1.content.count})
        case .wordAscending:
            return resultDiaries.sorted(by:{$0.content.count < $1.content.count})
        case .like:
            return resultDiaries.filter { $0.islike }.sorted { (d1, d2) -> Bool in
                if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
                    if date1.compare(date2) ==  .orderedDescending{
                        return true
                    }
                }
                return false
            }
        
    }
}

//MARK:-一个集合是否包含另外一个集合
func containSubArr(selectedTags: [String], diaryTags: [String]) -> Bool{
    for tag in selectedTags{
        if !diaryTags.contains(tag){
            return false
        }
    }
    return true
}
