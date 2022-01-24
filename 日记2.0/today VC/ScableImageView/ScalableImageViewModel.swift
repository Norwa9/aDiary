//
//  ScableImageViewModel.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView
import WXImageCompress
import AttributedString

class ScalableImageViewModel: NSObject {
    var image:UIImage?//image不是必须的
    
    var location:Int
    var bounds:CGRect
    var paraStyle:NSMutableParagraphStyle
    var contentMode:UIView.ContentMode = .scaleAspectFill
    var isEditing:Bool = false
    var shouldShowDoneView:Bool = false
    var uuid:String = ""
    
    
    // 添加图片时，创建viewModel
    init(location:Int,image:UIImage?) {
        // location
        self.location = location
        
        // image
        var imageAspectRation:CGFloat
        if let image = image{
            imageAspectRation = image.size.height / image.size.width
        }else{
            imageAspectRation = 1
        }
        let viewWidth = (globalConstantsManager.shared.kScreenWidth - 2 * 15) / userDefaultManager.imageScalingFactor
        let viewHeight = (viewWidth * imageAspectRation)
        self.bounds = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        let compressedImage = image?.wxCompress()
        self.image = compressedImage
        let uuid = UUID().uuidString // 插入图片时使用随机产生的uuid
        self.uuid = uuid
        let si = scalableImage(image: compressedImage, uuid: uuid)
        ImageTool.shared.addImages(SIs: [si]) // 创建viewModel的同时，创建它的si
        
        // paraStyle
        self.paraStyle = imageCenterParagraphStyle
        
        
        super.init()
    }
    
    // 读取model时创建viewModel
    init(model:ScalableImageModel){
        self.uuid = model.uuid
        self.image = ImageTool.shared.loadImage(uuid: self.uuid) // 新版本(>3.1)，从Realm读取图片
        self.location = model.location
        
        //恢复imageView的bounds，这个需要根据设备来适应
        let bounds = CGRect.init(string: model.bounds)
        ?? CGRect(x: 0, y: 0, width: globalConstantsManager.shared.kScreenWidth * 0.8, height: globalConstantsManager.shared.kScreenHeight * 0.8)
        let deviceAdaptatedWidth = globalConstantsManager.shared.kScreenWidth * model.viewScale
        let imageViewAspectRatio = bounds.height / bounds.width
        let deviceAdaptatedHeight = deviceAdaptatedWidth * imageViewAspectRatio
        self.bounds = CGRect(origin: .zero, size: CGSize(width: deviceAdaptatedWidth, height: deviceAdaptatedHeight))
        
        var paraStyle:NSMutableParagraphStyle
        switch model.paraStyle{
        case 0:
            paraStyle = imageLeftParagraphStyle
        case 1:
            paraStyle = imageCenterParagraphStyle
        case 2:
            paraStyle = imageRightParagraphStyle
        default:
            paraStyle = imageCenterParagraphStyle
        }
        self.paraStyle = paraStyle
        self.contentMode = UIImageView.ContentMode.init(rawValue: model.contentMode)!
        super.init()
    }
    
    typealias completionType = ()->(Void)
    ///view的location发生变化后，计算新的location
    func getNewestLocation(attributedString:NSAttributedString,completion:completionType){
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.attachment, in: fullRange, options: []) { object, range, stop in
            if let attchment = object as? SubviewTextAttachment{
                if let view = attchment.viewProvider.instantiateView(for: attchment, in: SubviewAttachingTextViewBehavior.init()) as? ScalableImageView{
                    if view.viewModel == self{
                        let newestLocation = range.location
                        self.location = newestLocation
                        print("newest location : \(newestLocation)")
                        completion()
                        stop.pointee = true
                        return
                    }
                }
                
            }
        }
    }
    
    ///viewModel转Model
    func generateModel() -> ScalableImageModel{
        var paraStyle:LWTextAligmentStyle
        if self.paraStyle == imageCenterParagraphStyle{
            paraStyle = .center
        }else if self.paraStyle == imageLeftParagraphStyle{
            paraStyle = .left
        }else{
            paraStyle = .right
        }
        
        let model = ScalableImageModel(location: location, bounds: bounds, paraStyle: paraStyle.rawValue,contentMode: contentMode.rawValue, uuid: uuid)
        return model
    }
    
}
