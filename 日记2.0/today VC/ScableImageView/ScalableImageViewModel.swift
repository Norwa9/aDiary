//
//  ScableImageViewModel.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit
import SubviewAttachingTextView

class ScalableImageViewModel: NSObject {
    var image:UIImage?//image不是必须的
    
    var location:Int
    var bounds:CGRect
    var paraStyle:NSMutableParagraphStyle
    var contentMode:UIView.ContentMode = .scaleAspectFill
    var isEditing:Bool = false
    
    
    ///构造默认view的viewModel
    init(location:Int,image:UIImage) {
        self.location = location
        self.image = image
        
        let imageAspectRation = image.size.height / image.size.width
        let viewWidth = (globalConstantsManager.shared.kScreenWidth - 2 * 15) / userDefaultManager.imageScalingFactor
        let viewHeight = (viewWidth / imageAspectRation)
        self.bounds = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        
        self.paraStyle = centerParagraphStyle
        super.init()
    }
    
    init(model:ScalableImageModel,image:UIImage){
        self.image = image
        self.location = model.location
        self.bounds = CGRect.init(string: model.bounds) ?? .zero
        var paraStyle:NSMutableParagraphStyle
        switch model.paraStyle{
        case 0:
            paraStyle = centerParagraphStyle
        case 1:
            paraStyle = leftParagraphStyle
        case 2:
            paraStyle = rightParagraphStyle
        default:
            paraStyle = centerParagraphStyle
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
        if self.paraStyle == centerParagraphStyle{
            paraStyle = .center
        }else if self.paraStyle == leftParagraphStyle{
            paraStyle = .left
        }else{
            paraStyle = .right
        }
        
        let model = ScalableImageModel(location: location, bounds: bounds, paraStyle: paraStyle.rawValue,contentMode: contentMode.rawValue)
        return model
    }
    
    
    func generateSubviewAttchmetn()->SubviewTextAttachment{
        let view = ScalableImageView(viewModel: self)
        let subViewAttchment = SubviewTextAttachment(view: view, size: bounds.size)
        return subViewAttchment
    }
    
}
