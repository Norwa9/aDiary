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
        
        // 未来的数据库更新...
        
    }
    
    // MARK: -3.2
    /// 3.2版本，升级数据库。遍历每篇日记，给每个image的viewModel都分配一个uuid，然后更新model；接着给每个image都创建图片对象si保存并上传到云端。
    private func upgradeDB32(){
        var count = 0
        let allCount = LWRealmManager.shared.localDatabase.count
        if allCount == 0{
            print("新用户不更新3.2DB")
            return // 新用户不用更新、已经标记过更新的不用再更新
        }
        if userDefaultManager.hasUpdated32{
            print("已经3.2DB更新过了")
            return
        }
        for diary in LWRealmManager.shared.localDatabase{
            guard let rtfd = diary.rtfd,let attrText:NSAttributedString = LoadRTFD(rtfd: rtfd) else {
                print("\(diary.date)没有富文本，跳过该循环")
                continue
            }
            let imageAttrTuples = diary.imageAttributesTuples
            let imageModels = diary.scalableImageModels
            var newImageModels = [ScalableImageModel]()
            for tuple in imageAttrTuples{
                let location = tuple.0
                if location >= attrText.length - 1{
                    print("跳过处理，防止：attribute at 的 Out of bounds")
                    continue
                }
                if let attchment = attrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment,let image = attchment.image(forBounds: .zero, textContainer: NSTextContainer(), characterIndex: location){
                    
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
                        }else{
                            // 不用重置uuid
                            newImageModels.append(model)
                        }
                    }else{
                        print("日期：\(diary.date),\(location)对应的图片model没有找到！提供默认model")
                        let defaultModel = self.generateSIModelAndUploadSI(location: location, image: image, dateCN: diary.date)
                        newImageModels.append(defaultModel)
                    }
                }
            }
            // 处理完一篇日记
            LWRealmManager.shared.update {
                diary.scalableImageModels = newImageModels
                diary.editedButNotUploaded = true
            }// 暂不上传，等到startEngine再上传
             // DiaryStore.shared.addOrUpdate(diary)
            count += 1
            print("3.2版本数据库更新进度进度：已处理\(count)篇")
        }
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

