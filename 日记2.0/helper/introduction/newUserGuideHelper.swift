//
//  newUserGuideHelper.swift
//  日记2.0
//
//  Created by yy on 2021/8/23.
//

import Foundation
import UIKit

class NewUserGuideHelper{
    static let shared = NewUserGuideHelper()
    
    //MARK:-导入用户引导
    public func initUserGuideDiary(){
        //设置App的默认字体
        userDefaultManager.fontName = "DINAlternate-Bold"
        
        
        //生成引导文案
        GenerateIntroductionDiary()
    }
    
    private func GenerateIntroductionDiary(){
        let date = GetTodayDate()
        if let page1Url = Bundle.main.url(forResource: "intro-page1", withExtension: "txt"),let page1Content = try? String(contentsOf: page1Url),
           let page2Url = Bundle.main.url(forResource: "intro-page2", withExtension: "txt"),let page2Content = try? String(contentsOf: page2Url){
            
            //page1
            let page1 = diaryInfo(dateString: date)
            let attributedText = NSMutableAttributedString(string: page1Content)
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
            page1.content = plainText
            page1.rtfd = attributedText.data()
            page1.todoAttributesTuples = todoAttrTuples
            page1.imageAttributesTuples = imageAttrTuples
            page1.containsImage = containsImage
            page1.todos = incompletedTodos
            page1.emojis.append("👏🏻")
            page1.emojis.append("😘")
            page1.tags.append("你好新用户")
            dataManager.shared.tags.append("你好新用户")
            page1.ckData = "不需要上传".data(using: .utf8)//TODO:(未测试)随便给ckData赋值，强行标记引导日记为已上传，防止第二设备下载App后今日的日记被覆盖
            
            //page2
            let page2Date = date + "-1"
            let page2 = diaryInfo(dateString: page2Date)
            page2.content = page2Content
            page2.emojis.append("2️⃣")
            page2.ckData = "不需要上传".data(using: .utf8)
            
            //添加到本地数据库
            if LWRealmManager.shared.queryFor(dateCN: date).isEmpty{
                LWRealmManager.shared.add(page1)
            }
            if LWRealmManager.shared.queryFor(dateCN: page2Date).isEmpty{
                LWRealmManager.shared.add(page2)
            }
            
        }
    }
}
