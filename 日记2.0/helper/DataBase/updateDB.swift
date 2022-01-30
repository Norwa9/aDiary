//
//  updateDB.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/23.
//

import Foundation
import UIKit

class LWDBUpdater{
    static let shared = LWDBUpdater()
    
    
    func checkDBUpdate(){
        // 1. 版本3.2进行了数据库的更新[2022.1.23]
        upgradeDB32()
    }
    
    // MARK: -3.2
    /// 3.2版本，升级数据库。遍历每篇日记，给每个image的viewModel都分配一个uuid，然后更新model；接着给每个image都创建图片对象si保存并上传到云端。
    private func upgradeDB32(){
        var count = 0
        let allCount = LWRealmManager.shared.localDatabase.count
        
        /*
         1. 旧用户(<3.2版本)正常更新
         2. 旧用户(<3.2版本)卸载重装（忽略）
         3. 新用户正常安装
         3. 新用户卸载后重装
         */
        if userDefaultManager.hasUpdated32{
            print("已被标记为已升级，跳过升级3.2DB")
//              return
        }
        for diary in LWRealmManager.shared.localDatabase{
//        for diary in diariesForMonth(forYear: 2022, forMonth: 3){
            guard
                let rtfd = diary.rtfd,
                let attrText:NSAttributedString = LoadRTFD(rtfd: rtfd),
                diary.date != ""
            else {
                print("\(diary.date)没有富文本，跳过该循环")
                continue
            }
            let muAttrText:NSMutableAttributedString =  NSMutableAttributedString(attributedString: attrText)
            
            // image
            let imageAttrTuples = diary.imageAttributesTuples
            let imageModels = diary.scalableImageModels
            var newImageModels = [ScalableImageModel]()
            
            // todo
            let todoAttrTuples = diary.todoAttributesTuples
            var newTodoModels = [LWTodoModel]()
            
            
            // 1. 升级图片
            for tuple in imageAttrTuples{
                if let uuid = imageModels.first?.uuid{
                    if uuid != ""{
                        print("处理到\(diary.date)的日记，该日记图片已升级")
                        break
                    }
                }
                let location = tuple.0
                if location >= muAttrText.length - 1{
                    // 处理最后一个字符的图片时，attribute at 会out of bounds
                    // 为了能够迁移这种图片，这里的解决办法是直接给日记再在末尾添加很多个空格" "，以防止out of bounds报错。
                    print("location >= muAttrText.length - 1，旧日记长度:\(muAttrText.length)")
                    for _ in 0...location{
                        muAttrText.append(NSAttributedString(string: " "))
                    }
                    print("新日记长度:\(muAttrText.length)")
                }
                if let attchment = muAttrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment,let image = attchment.image(forBounds: .zero, textContainer: NSTextContainer(), characterIndex: location){
                    print("处理到\(diary.date),\(location)处的图片")
                    
                    if let model = imageModels.filter({$0.location == location}).first{
                        if model.uuid == ""{
                            // 不能随机初始化UUID，因为如果iPad也运行了数据库更新函数，
                            // iPhone和iPad相同日期下的图片的uuid因为是随机的所以不一样，会导致同步发生错误！
                            let uuid = diary.date + "\(location)"
                            print("日期：\(diary.date),\(location)对应的图片model找到，更新其uuid为:\(uuid)")
                            model.uuid = uuid
                            let si = scalableImage(image: image, uuid: uuid)
                            ImageTool.shared.addImages(SIs: [si], needUpload: false) // 暂不上传，等到startEngine再上传
                            newImageModels.append(model)
                        }else{ // 忽略在测试阶段已经升级过的图片
                            newImageModels.append(model)
                        }
                    }else{
                        print("日期：\(diary.date),\(location)对应的图片model没有找到！提供默认model")
                        let defaultModel = self.generateSIModelAndUploadSI(location: location, image: image, dateCN: diary.date)
                        newImageModels.append(defaultModel)
                    }
                }
            }
            
            // 2. 升级todo
            if diary.lwTodoModels.isEmpty{ // 忽略在测试阶段已经升级过的todo
                for todoTuple in todoAttrTuples{
                    // (1)获取todo所在段落p
                    let location = todoTuple.0
                    let state = todoTuple.1
                    let range = NSRange(location: location, length: 1)
                    let pRange = muAttrText.mutableString.paragraphRange(for: range)
                    
                    // (2)用todo的location和段落文字来构建todoModel
                    let pContent = muAttrText.attributedSubstring(from: pRange).string
                    var contentRange:NSRange
                    if pContent.contains("\n"){
                        contentRange = NSRange(location: pRange.location, length: pRange.length - 1) // 不要末尾的换行符
                    }else{
                        contentRange = pRange
                    }
                    let content = muAttrText.attributedSubstring(from: contentRange).string
                    
                    
                    let todoViewModel = LWTodoViewModel(location: location)
                    todoViewModel.content = content
                    todoViewModel.state = state
                    todoViewModel.dateBelongs = diary.date // 设置该todo所属于的日记id
                    let todoModel = todoViewModel.generateModel()
                    
                    // (3)将旧的todo内容用空格覆盖
                    let oldContentRange = NSRange(location: pRange.location + 1, length: pRange.length - 1)
                    var replacingBlankString = ""
                    for _ in 0..<oldContentRange.length - 1{
                        replacingBlankString += " "
                    }
                    replacingBlankString.append("\n")
                    muAttrText.replaceCharacters(in: oldContentRange, with: replacingBlankString)
                    
                    newTodoModels.append(todoModel)
                    print("处理到\(diary.date),\(location)处的todo，内容为\(content)")
                }
            }
            
            // 3. 处理一篇日记完成
            LWRealmManager.shared.update {
                // 如果新的model数组为空，则不更新，防止原有数值被空数组覆盖
                if !newImageModels.isEmpty{
                    diary.scalableImageModels = newImageModels
                }
                if !newTodoModels.isEmpty{
                    diary.lwTodoModels = newTodoModels
                    diary.rtfd = muAttrText.toRTFD()
                }
                if !newImageModels.isEmpty || !newTodoModels.isEmpty{
                    // 图片或todo其中之一发生更新，才需要上传
                    diary.editedButNotUploaded = true
                }
            }// 暂不上传，等到startEngine再上传
            count += 1
            print("3.2版本数据库更新进度进度：已处理\(count)篇")
        }
        
        // 4. 所有日记完成遍历
        userDefaultManager.hasUpdated32 = true
        print("3.2版本数据库更新完成")
    }
    
    private func generateSIModelAndUploadSI(location: Int, image: UIImage?, dateCN:String) -> ScalableImageModel{
        // image
        var imageAspectRation:CGFloat
        if let image = image{
            imageAspectRation = image.size.height / image.size.width
        }else{
            imageAspectRation = 1
        }
        let viewWidth = (globalConstantsManager.shared.kScreenWidth - 2 * 15) / userDefaultManager.imageScalingFactor
        let viewHeight = (viewWidth * imageAspectRation)
        let bounds = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        let compressedImage = image?.wxCompress()
        let uuid = dateCN + "\(location)" // 不能使用UUID()随机生成，否者多端的同一图片的uuid不一致
        
        // paraStyle
        let paraStyle:LWTextAligmentStyle = .center
        
        // contentMode
        let contentMode:UIView.ContentMode = .scaleAspectFill
        
        // 顺便上传
        let si = scalableImage(image: compressedImage, uuid: uuid)
        ImageTool.shared.addImages(SIs: [si],needUpload: false) // 创建viewModel的同时，创建它的si
        // 暂不上传，等到startEngine再上传
        
        let model = ScalableImageModel(location: location, bounds: bounds, paraStyle: paraStyle.rawValue,contentMode: contentMode.rawValue, uuid: uuid)
        return model
        
    }
}

