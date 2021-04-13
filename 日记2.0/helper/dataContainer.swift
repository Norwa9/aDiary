//
//  dataContainer.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/13.
//

import Foundation
import UIKit

import Foundation
import UIKit


class diaryInfo:Codable{
    var date:String?
    var content:String = ""
    var islike:Bool = false
    var tags = [String]()
    var mood:moodTypes = .calm
    var uuidofPictures = [String]()
    init(dateString:String?) {
        date = dateString
    }
}

//结构体用于定义保存到UserDefaults的数据的key
struct DefaultsKeys
{
    static let diaryDict  = "diaryDict2.0"
    static let hasInitialized  = "hasInitialized"
    static let tags = "tags"
}
//单例
//它是一个用以保存app数据的类。能够在几个类之间共享。
//它设置一个观察者，当app到后台时，自动将app数据保存到UserDefaults。
//使用方法：通过语句`DataContainerSingleton.sharedDataContainer`来访问这个单例。
class DataContainerSingleton {
    static let sharedDataContainer = DataContainerSingleton()
    
    var hasInitialized = false
    var diaryDict = [String:diaryInfo]()
    var attributedDiaryDict = [String:NSAttributedString]()
    var selectedDiary:diaryInfo!
    var tags = [String]()
    
    var goToBackgroundObserver: AnyObject?
    init(){
        let defaults = UserDefaults.standard
        //-----------------------------------------------------------------------------
        //读取。从UserDefaults读取
        hasInitialized = defaults.value(forKey: DefaultsKeys.hasInitialized) as? Bool ?? false
        tags = defaults.value(forKey: DefaultsKeys.tags) as? [String] ?? [String]()
        if let savedNotes = defaults.object(forKey: DefaultsKeys.diaryDict) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                diaryDict = try jsonDecoder.decode([String:diaryInfo].self, from: savedNotes)
            } catch {
                print("Failed to load dict")
            }
        }
        //-----------------------------------------------------------------------------
        //保存。当app退出到后台，保存数据到UserDefaults
        print("进入后台，保存数据")
        goToBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,object: nil,queue: nil){(note: Notification!) -> Void in
            let defaults = UserDefaults.standard
            defaults.setValue(self.hasInitialized, forKey: DefaultsKeys.hasInitialized)
            defaults.setValue(self.tags, forKey: DefaultsKeys.tags)
            let jsonEncoder = JSONEncoder()
            if let storedData = try? jsonEncoder.encode(self.diaryDict) {
                defaults.set(storedData, forKey:DefaultsKeys.diaryDict)
            } else {
              print("Failed to save dict.")
            }
        }
        //-----------------------------------------------------------------------------
        //初始化今日界面的数据：初始化selected Diary为今日的日记
        //如果今天已经有日记，返回今天日记；没有的话就创建一个空的模板
        let dateTodayString = getTodayDate()
        if let diary = diaryDict[dateTodayString]{
            selectedDiary =  diary
        }else{
            diaryDict[dateTodayString] = diaryInfo(dateString: dateTodayString)
            selectedDiary = diaryDict[dateTodayString]
        }
    }
}


//MARK:-导入日记
func initialDiaryDict(){
    print("initialDiaryDict() called")
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"
    //如果之前没有导入过
//    if true{
    if !DataContainerSingleton.sharedDataContainer.hasInitialized{//注意，第一次使用sharedDataContainer将调用单例的init()，此语句是第一次使用
        DataContainerSingleton.sharedDataContainer.hasInitialized = true
        DataContainerSingleton.sharedDataContainer.diaryDict.removeAll()//清空
        let dict = txt2String(fileName: "demoDiaries")
        for key in dict.keys{
            let dateString = formatter.string(from: key)
            let tempDiary = diaryInfo(dateString: dateString)
            //读取key（日期）对应的String（日记内容）
            tempDiary.content = dict[key] ?? ""
            //读取内容后，初始化日记的textViewAttributedText属性
            
            DataContainerSingleton.sharedDataContainer.diaryDict[dateString] = tempDiary
        }
    }
}

func txt2String(fileName:String) -> [Date:String]{
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d EEEE yyyy"
    var count = 0
    var date = Date()
    var content = ""
    var dateDict = [Date:String]()
    if let levelFileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") {
        if let levelContents = try? String(contentsOf: levelFileURL) {
            let lines = levelContents.components(separatedBy: "\n")
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
        }
    }
    return dateDict
}

//MARK:-获取指定日期的日记
func diariesForMonth(forYear:Int,forMonth:Int)->[diaryInfo?]{
    let diaryDict = DataContainerSingleton.sharedDataContainer.diaryDict
//    print("diariesForMonth() called,diaryDict.count:\(diaryDict.count)")
    var tempDiaries = [diaryInfo?]()
    
    if forYear == 0 && forMonth == 0{
        //0,0是特例：表示返回所有日记
        for (_,diary) in diaryDict{
            tempDiaries.append(diary)
        }
        
        //返回日期降序的所有日记
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy年M月d日"
        return tempDiaries.sorted { (d1, d2) -> Bool in
            if let date1 = dateFomatter.date(from: d1!.date!) ,let date2 = dateFomatter.date(from: d2!.date!){
                if date1.compare(date2) ==  .orderedAscending{
                    return true
                }
            }
            return false
        }
    }
    
    for i in 1...howManyDaysInThisMonth(year: forYear, month: forMonth){
        let timeString = "\(forYear)年\(forMonth)月\(i)日"
//        print(timeString)
        let diary = diaryForDate(atTime: timeString)
//        print(diary)
        tempDiaries.append(diary)
    }
    return tempDiaries
}

//MARK:-获取符合筛选条件的所有日记
func diariesForConditions(
    keywords:String?,selectedMood:moodTypes?,selectedTags:[String],numsToShow:Int)->[diaryInfo?]{
    let diaryDict = DataContainerSingleton.sharedDataContainer.diaryDict

    var resultDiaries = [diaryInfo?]()
    
    //筛选指定条件的日记
    for (_,diary) in diaryDict{
        if selectedMood != nil && diary.mood != selectedMood{
            continue
        }
        if !containSubArr(selectedTags: selectedTags, diaryTags: diary.tags){
            continue
        }
        resultDiaries.append(diary)
    }
    
    //如果有指定关键词，再继续筛选出包含关键词的日记
    if keywords != ""{
        resultDiaries = resultDiaries.filter { (item: diaryInfo?) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item!.content.range(of: keywords!, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
    }
    
    //按字数排序结果
    resultDiaries = resultDiaries.sorted(by:{$0!.content.count > $1!.content.count})
    
    if numsToShow == 0{//0表示特例：展示所有
        return resultDiaries.reversed()
    }
    else if resultDiaries.count > numsToShow{
        return resultDiaries.dropLast(resultDiaries.count - numsToShow).reversed()
    }else{
        return resultDiaries.reversed()
    }
}

func containSubArr(selectedTags: [String], diaryTags: [String]) -> Bool{
    for tag in selectedTags{
        if !diaryTags.contains(tag){
            return false
        }
    }
    return true
}


func diaryForDate(atTime:String) -> diaryInfo?{
    if let selectedDiary = DataContainerSingleton.sharedDataContainer.diaryDict[atTime]{
        return selectedDiary
    }else{
        return nil
    }
}
