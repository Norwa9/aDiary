//
//  LWDiary.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/5.
//

import Foundation
import UIKit

class diaryInfo:Codable{
    var date:String?
    var content:String = ""
    var islike:Bool = false
    var tags = [String]()
    var mood:moodTypes = .calm
    var uuidofPictures = [String]()
    var containsImage:Bool?
    
    init(dateString:String?) {
        date = dateString
    }
}

//MARK:-Getter属性
extension diaryInfo{
    var year:Int{
        get{
            if let dateString = self.date{
                return Int(dateString.dateComponent(for: .year))!
            }else{
                return -1
            }
        }
    }
    var month:Int{
        get{
            if let dateString = self.date{
                return Int(dateString.dateComponent(for: .month))!
            }else{
                return -1
            }
        }
    }
    var day:Int{
        get{
            if let dateString = self.date{
                return Int(dateString.dateComponent(for: .day))!
            }else{
                return -1
            }
        }
    }
    
    var weekDay:String{
        get{
            if let dateString = self.date{
                //系统语言是中文环境下，返回的weekDay即是"周一"
                //系统语言是英文环境下，返回的weekDay是"Mon"
                let weekDay =  dateString.dateComponent(for: .weekday)
                return weekDaysCN[weekDay] ?? weekDay
            }else{
                return ""
            }
        }
    }
    
    var row:Int{
        get{
            let diries = diariesForMonth(forYear: year, forMonth: month)
            var count = 0
            for diary in diries.reversed(){
                if let d = diary{
                    if d.date == self.date{
                        return count
                    }
                    count += 1
                }
            }
            return -1
        }
    }
}
