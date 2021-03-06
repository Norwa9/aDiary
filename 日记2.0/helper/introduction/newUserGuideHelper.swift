//
//  newUserGuideHelper.swift
//  日记2.0
//
//  Created by yy on 2021/8/23.
//

import Foundation
import UIKit
import SubviewAttachingTextView
import AttributedString

class NewUserGuideHelper{
    static let shared = NewUserGuideHelper()
    
    //MARK:-导入用户引导
    public func initUserGuideDiary(){
        if userDefaultManager.hasInitialized{
            userDefaultManager.needShowWelcome = false // 老用户已经初始化过了
            return
        }
        
        // 1.设置App的默认字体
        // userDefaultManager.fontName = "DINAlternate-Bold"
        userDefaultManager.fontName = nil // 使用苹果默认字体
        
        
        // 2.生成引导日记
        GenerateIntroductionDiary()
        
        
        // 3.生成引导日记成功
        userDefaultManager.hasInitialized = true
        print("引导日记创建成功")
    }
    
    private func GenerateIntroductionDiary(){
        let date = GetTodayDate()
        if let page1Url = Bundle.main.url(forResource: "intro-page1", withExtension: "txt"),let page1Content = try? String(contentsOf: page1Url),
           let page2Url = Bundle.main.url(forResource: "intro-page2", withExtension: "txt"),let page2Content = try? String(contentsOf: page2Url){
            
            //page1
            let page1 = diaryInfo(dateString: date)
            // add image
            page1.scalableImageModels = self.generateExampleImageModels(imagesLocations: [558])
            
            // add todos
            page1.lwTodoModels = self.generateExampleTodoModels(todoLocations: [69,71,73])
            
            // rtfd
            let userFont = userDefaultManager.font
            let userParaStyle = NSMutableParagraphStyle()
            userParaStyle.lineSpacing = userDefaultManager.lineSpacing
            let userAttributes : [NSAttributedString.Key : Any] = [
                .font : userFont,
                .paragraphStyle : userParaStyle,
                .foregroundColor : UIColor.label
            ]
            let attributedText = NSAttributedString(string: page1Content).addingAttributes(userAttributes)
            
            // 其他
            page1.content = page1Content.parsePlainText()
            page1.rtfd = attributedText.toRTFD()
            page1.containsImage = true
            page1.emojis.append("👏🏻")
            page1.emojis.append("😘")
            page1.tags.append("你好新用户")
            dataManager.shared.tags.append("你好新用户")
            page1.ckData = "不需要上传".data(using: .utf8)//TODO:(未测试)随便给ckData赋值，强行标记引导日记为已上传，防止第二设备下载App后今日的日记被覆盖
            
            
            //page2
            let page2Date = date + "-1"
            let page2 = diaryInfo(dateString: page2Date)
            let page2AttributedString = NSMutableAttributedString(string: page2Content)
            page2AttributedString.addAttributes(userAttributes, range: NSRange(location: 0, length: page2AttributedString.length))
            page2.content = page2Content.parsePlainText()
            page2.rtfd = page2AttributedString.toRTFD()
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
    
    /// 在欢迎日记添加图片
    private func generateExampleImageModels(imagesLocations:[Int])-> [ScalableImageModel] {
        return imagesLocations.map { location in
            let viewModel = ScalableImageViewModel(location: location, image: UIImage(named:"icon-1024"))
            let model = viewModel.generateModel()
            return model
        }
        
        
    }
    
    
    private func generateExampleTodoModels(todoLocations:[Int])->[LWTodoModel]{
        var todoModels:[LWTodoModel] = []
        let todoViewModel0 = LWTodoViewModel(location: todoLocations[0])
        todoViewModel0.content = "试试完成这个待办事项"
        todoViewModel0.dateBelongs = GetTodayDate()
        todoModels.append(todoViewModel0.generateModel())
        
        let todoViewModel1 = LWTodoViewModel(location: todoLocations[1])
        todoViewModel1.content = "待办可设置高级选项：提醒时间和备注"
        todoViewModel1.dateBelongs = GetTodayDate()
        if let tonightDate = self.getTonightDate(){
            todoViewModel1.needRemind = false // 为了触发通知权限，给用户手动去开启通知
            todoViewModel1.remindDate = tonightDate
        }
        todoViewModel1.note = "总结一下今天"
        let h = todoViewModel1.calSingleRowTodoViewHeihgt()
        todoViewModel1.bounds = CGRect(origin: .zero, size: CGSize(width: todoViewModel1.bounds.width, height: h))
        todoModels.append(todoViewModel1.generateModel())
        
        let todoViewModel2 = LWTodoViewModel(location: todoLocations[2])
        todoViewModel2.content = "日记中写下的待办会在主页显示"
        todoViewModel2.dateBelongs = GetTodayDate()
        todoModels.append(todoViewModel2.generateModel())
        return todoModels
    }
    
    private func getTonightDate()->Date?{
        let downloadDate = Date()
        let yyyy = getDateComponent(for: downloadDate, for: .year)
        let M = getDateComponent(for: downloadDate, for: .month)
        let d = getDateComponent(for: downloadDate, for: .day)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d-hh:mm"
        
        let tonightDate = formatter.date(from: "\(yyyy)-\(M)-\(d)-00:00")
        // print("tonightDate:\(tonightDate)")
        return tonightDate
    }
}
