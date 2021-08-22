//
//  diary+subPages.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/22.
//

import Foundation

extension diaryInfo{
    ///引入多页面后，date不一定就是真实的日期了
    ///用这个计算属性计算真实的日记，如2021年9月14日-1 -> 2021年9月14日
    var trueDate:String{
        get{
            return self.date.parsePageDate()
        }
    }
    
    ///本页面在所有页面（主页+子页面）的下标
    ///注意：按序号大小排序
    var indexOfPage:Int{
        get{
            if !date.contains("-"){
                return 0
            }else{
                let orderedSubPages = LWRealmManager.shared.querySubpages(ofDate: trueDate)
                let subPageIndex = orderedSubPages.firstIndex(of: self)!//在子页中的下标
                return subPageIndex + 1 //1表示主页
            }
        }
    }

}
