//
//  filterModel.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/20.
//

import Foundation
import UIKit

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
    
    ///根据条件异步筛选日记
    typealias filterCompletion = ( ([diaryInfo]) -> Void)?
    public func filter(completionHandler: filterCompletion ){
        let res = self.filterDiary()//0.5s左右
        completionHandler?(res)
    }
    
    //MARK:-获取符合筛选条件的所有日记
    private func filterDiary()->[diaryInfo]{
        //------Background Thread-------
        
        let keywords = filterHelper.shared.searchText
        let selectedTags = filterHelper.shared.selectedTags
        let sortStyle = filterHelper.shared.selectedSortstyle
        
        //不能在后台线程访问主线程创建的realm对象
        //❌let localDB = LWRealmManager.shared.localDatabase
        let allDiary = LWRealmManager.queryAllDieryOnCurrentThread()
        print("allDiary.count:\(allDiary.count)")
        var resultDiaries = [diaryInfo]()
        
        //1筛选：关键字
        if keywords != ""{
            resultDiaries = allDiary.filter { (item: diaryInfo) -> Bool in
                let content = item.content + item.todos.joined()//正文+todo
                return content.range(of: keywords, options: .caseInsensitive, range: nil, locale: nil) != nil
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
}
