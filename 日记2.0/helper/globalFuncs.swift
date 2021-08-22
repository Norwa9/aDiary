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
    let date = GetTodayDate()
    if let levelFileURL = Bundle.main.url(forResource: "introduction", withExtension: "txt"),let content = try? String(contentsOf: levelFileURL){
        //1.设置引导的文案：图片、待办、标签···
        let introDiary = diaryInfo(dateString: date)
        let attributedText = NSMutableAttributedString(string: content)
        attributedText.loadCheckboxes()
        let iconAttchment = GetAttachment(image:UIImage(named:"icon-1024")!)
        attributedText.insert(iconAttchment, at: attributedText.length)
        let parseRes = attributedText.parseAttribuedText()
        let imageAttrTuples = parseRes.0
        let todoAttrTuples = parseRes.1
        let text = parseRes.2
        let containsImage = parseRes.3
        let incompletedTodos = parseRes.4
        let allTodos = parseRes.6
        let plainText = TextFormatter.parsePlainText(text: text,allTodos: allTodos)
        introDiary.content = plainText
        introDiary.rtfd = attributedText.data()
        introDiary.todoAttributesTuples = todoAttrTuples
        introDiary.imageAttributesTuples = imageAttrTuples
        introDiary.containsImage = containsImage
        introDiary.todos = incompletedTodos
        introDiary.emojis.append("👏🏻")
        introDiary.emojis.append("😘")
        introDiary.tags.append("你好新用户")
        dataManager.shared.tags.append("你好新用户")
        
        //2.TODO:(未测试)随便给ckData赋值，强行标记引导日记为已上传，防止第二设备下载App后今日的日记被覆盖
        introDiary.ckData = "不需要上传".data(using: .utf8)
        
        //3.指定新的默认字体
        userDefaultManager.fontName = "DINAlternate-Bold"
        
        if LWRealmManager.shared.queryFor(dateCN: date).isEmpty{
            LWRealmManager.shared.add(introDiary)
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
    
    //过滤掉子页面
    let mainPage = unsortedResult.filter { (d) -> Bool in
        if let _ = d.date.firstIndex(of: "-"){
            return false
        }else{
            return true
        }
    }
    
    //按日期排序
    let dateFomatter = DateFormatter()
    dateFomatter.dateFormat = "yyyy年M月d日"
    let sortedDiaries = mainPage.sorted { (d1, d2) -> Bool in
        if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
            if date1.compare(date2) ==  .orderedDescending{
                return true
            }
        }
        return false
    }
    
    return sortedDiaries
    
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


//MARK:-读取rtfd文件
func LoadRTFD(rtfd:Data?) -> NSAttributedString?{
    let aString:NSAttributedString?
    if let rtfd = rtfd{
        do {
            try aString =  NSAttributedString(data: rtfd, options: [.documentType:NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8], documentAttributes: nil)
        } catch{
            aString = nil
        }
    }else{
        aString = nil
    }
    return aString
}
