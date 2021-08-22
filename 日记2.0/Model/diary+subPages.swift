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
}
