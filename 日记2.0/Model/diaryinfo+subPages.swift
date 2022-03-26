//
//  diary+subPages.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/22.
//

import Foundation

extension diaryInfo{
    ///是否是主页面
    var isMainPage:Bool{
        get{
            if date.contains("-"){
                return false
            }else{
                return true
            }
        }
    }
    ///引入多页面后，date不一定就是真实的日期了
    ///用这个计算属性计算真实的日记，如2021年9月14日-1 -> 2021年9月14日
    var trueDate:String{
        get{
            return self.date.parsePageDate()
        }
    }
    
    ///本页面在所有页面（主页+子页面）的下标（注意：按后缀大小排序后的序号）
    ///后续引入删除功能后，用这个属性获取页面的序号比较稳妥。
    var indexOfPage:Int{
        get{
            if !date.contains("-"){
                // 主页面
                return 0
            }else{
                return metaData.pageIndex
            }
        }
    }

}
