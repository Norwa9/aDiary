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
    
    func clear(){
        self.searchText = ""
        self.selectedTags.removeAll()
        self.selectedSortstyle = .dateDescending
    }
    
    /// -根据已选条件筛选日记
    public func filter()->([diaryInfo],Int,Int){
        let keywords = searchText
        let selectedTags = selectedTags
        let sortStyle = selectedSortstyle
        
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
        
        
        //2 过滤掉模板
        resultDiaries = resultDiaries.filter{ (diary: diaryInfo) -> Bool in
            if diary.date.starts(with: LWTemplateHelper.shared.TemplateNamePrefix){
                return  false
            }else{
                return true
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
                resultDiaries = resultDiaries.sorted { (d1, d2) -> Bool in
                    if let date1 = dateFomatter.date(from: d1.trueDate) ,let date2 = dateFomatter.date(from: d2.trueDate){
                        if date1.compare(date2) ==  .orderedDescending{
                            return true
                        }
                        //如果日期一样，页面号小的排在前
                        if date1.compare(date2) == .orderedSame{
                            let pageIndex1 = d1.indexOfPage
                            let pageIndex2 = d2.indexOfPage
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
                            let pageIndex1 = d1.indexOfPage
                            let pageIndex2 = d2.indexOfPage
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
