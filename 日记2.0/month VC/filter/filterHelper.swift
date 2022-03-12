//
//  filterModel.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/20.
//

import Foundation
import UIKit
import RealmSwift

class filterHelper {
    static let shared = filterHelper()
    
    var searchText:String = ""
    var selectedTags = [String]()
    var selectedSortstyle:sortStyle = .dateDescending
    var notificationToken:NotificationToken!
    func clear(){
        self.searchText = ""
        self.selectedTags.removeAll()
        self.selectedSortstyle = .dateDescending
    }
    
    ///根据条件异步筛选日记
    typealias filterCompletion = ( (_ res:[diaryInfo],_ num:Int,_ wordCount:Int) -> Void)?
    public func filter(completionHandler: filterCompletion ){
        let res = self.filterDiary()//0.5s左右
        completionHandler?(res.0,res.1,res.2)
    }
    
    //MARK:-获取符合筛选条件的所有日记
    private func filterDiary()->([diaryInfo],Int,Int){
        let keywords = filterHelper.shared.searchText
        let selectedTags = filterHelper.shared.selectedTags
        let sortStyle = filterHelper.shared.selectedSortstyle
        
        let allDiary = LWRealmManager.shared.localDatabase
        
        let pages = allDiary
        var resultDiaries = [diaryInfo]()
        
        //1筛选：关键字(日记与todo)
        if keywords != ""{
            resultDiaries = pages.filter { (item: diaryInfo) -> Bool in
                let todoModels = item.lwTodoModels
                var content = item.content
                for model in todoModels{
                    content += model.content + model.note
                }
                return content.range(of: keywords, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }else{
            //如果没有关键词，返回所有日记
            print("无关键词")
            for diary in pages{
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
                resultDiaries = resultDiaries.sorted { (d1, d2) -> Bool in
                    if let date1 = dateFomatter.date(from: d1.trueDate) ,let date2 = dateFomatter.date(from: d2.trueDate){
                        if date1.compare(date2) ==  .orderedDescending{
                            return true
                        }
                        //如果日期一样，页面号小的排在前
                        if date1.compare(date2) == .orderedSame{
                            let pageIndex1 = d1.date.parseDateSuffix()
                            let pageIndex2 = d2.date.parseDateSuffix()
                            return pageIndex1 < pageIndex2
                        }
                    }
                    return false
                }
            case .dateAscending:
                resultDiaries =  resultDiaries.sorted { (d1, d2) -> Bool in
                    if let date1 = dateFomatter.date(from: d1.trueDate) ,let date2 = dateFomatter.date(from: d2.trueDate){
                        if date1.compare(date2) ==  .orderedAscending{
                            return true
                        }
                        //如果日期一样，页面号小的排在前
                        if date1.compare(date2) == .orderedSame{
                            let pageIndex1 = d1.date.parseDateSuffix()
                            let pageIndex2 = d2.date.parseDateSuffix()
                            return pageIndex1 < pageIndex2
                        }
                    }
                    return false
                }
            case .wordDescending:
                resultDiaries =  resultDiaries.sorted(by:{$0.content.count > $1.content.count})
            case .wordAscending:
                resultDiaries = resultDiaries.sorted(by:{$0.content.count < $1.content.count})
            case .like:
                resultDiaries = resultDiaries.filter { $0.islike }.sorted { (d1, d2) -> Bool in
                    if let date1 = dateFomatter.date(from: d1.date) ,let date2 = dateFomatter.date(from: d2.date){
                        if date1.compare(date2) ==  .orderedDescending{
                            return true
                        }
                    }
                    return false
                }
        }
        
        //篇数
        let count = resultDiaries.count
        
        //字数
        var wordCount = 0
        for diary in resultDiaries{
            wordCount += diary.content.count
        }
        
        return (resultDiaries,count,wordCount)
    }
}
