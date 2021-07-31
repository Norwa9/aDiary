//
//  globalFuncs.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/5.
//

import Foundation
import UIKit
import RealmSwift

//MARK:-导入用户引导
func LoadIntroText(){
    if !userDefaultManager.hasInitialized{
        userDefaultManager.hasInitialized = true
        let date = GetTodayDate()
        if let levelFileURL = Bundle.main.url(forResource: "introduction", withExtension: "txt") {
            if let textContents = try? String(contentsOf: levelFileURL) {
                let introDiary = diaryInfo(dateString: date)
                introDiary.content = textContents
                LWRealmManager.shared.add(introDiary)
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
    for (date,content) in diaryDict{
        let dateString = formatter.string(from: date)
        
        let newDiary = diaryInfo(dateString: dateString)
        newDiary.content = content
        LWRealmManager.shared.add(newDiary)
        
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
func diariesForMonth(forYear:Int,forMonth:Int)->[diaryInfo]{
    var unsortedResult:Results<diaryInfo>
    //1.特例：表示返回所有日记
    if forYear == 0 && forMonth == 0{
        let tempResults = LWRealmManager.shared.localDatabase
        unsortedResult = tempResults
    }else{
        //2，返回指定年/月日记
        let predicate = NSPredicate(format: "year == %d AND month == %d", forYear,forMonth)
        let filteredResults = LWRealmManager.shared.query(predicate: predicate)
        unsortedResult = filteredResults
    }
    
    //按日期排序
    let dateFomatter = DateFormatter()
    dateFomatter.dateFormat = "yyyy年M月d日"
    let sortedDiaries = unsortedResult.sorted { (d1, d2) -> Bool in
        if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
            if date1.compare(date2) ==  .orderedDescending{
                return true
            }
        }
        return false
    }
    return sortedDiaries
    
}

//MARK:-获取符合筛选条件的所有日记
func filterDiary()->[diaryInfo]{
    //------Background Thread-------
    
    let keywords = filterModel.shared.searchText
    let selectedTags = filterModel.shared.selectedTags
    let sortStyle = filterModel.shared.selectedSortstyle
    
    //不能在后台线程访问主线程创建的realm对象
    //❌let localDB = LWRealmManager.shared.localDatabase
    let allDiary = LWRealmManager.queryAllDieryOnCurrentThread()
    print("allDiary.count:\(allDiary.count)")
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
    
    //2筛选：心情和标签(已去除)
    
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




// MARK: String转元组[(Int,Int)]数组
func dictString2Tuples(_ str: String) -> [(Int,Int)]{
    let data = str.data(using: String.Encoding.utf8)
    if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : String] {
        let tuples = dict.map { (key, value) in
            return (Int(key)!,Int(value)!)
        }
        return tuples
    }
    return []
}

// MARK: 元组[(Int,Int)]转String
func tuples2dictString(_ tuples:[(Int,Int)]) -> String?{
    var dic = [String:String]()
    for tuple in tuples{
        dic["\(tuple.0)"] = "\(tuple.1)"
    }
    
    let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
    let str = String(data: data!, encoding: String.Encoding.utf8)
    return str
}


