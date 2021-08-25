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
    var location:Int
    var image:UIImage
    var bounds:CGRect
    var paraStyle:NSMutableParagraphStyle
    var contentMode:UIView.ContentMode = .scaleAspectFill
    var isEditing:Bool = false
    
    init(location:Int,image:UIImage,bounds:CGRect,paraStyle:NSMutableParagraphStyle = centerParagraphStyle) {
        self.location = location
        self.image = image
        self.bounds = bounds
        self.paraStyle = paraStyle
        super.init()
    }
    
    init(model:ScalableImageModel){
        self.location = model.location
        self.image = UIImage(data: model.imageData) ?? #imageLiteral(resourceName: "bg")
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
        
        let boundsSring = "\(bounds.origin.x),\(bounds.origin.y),\(bounds.size.width),\(bounds.size.height)"
        let model = ScalableImageModel(location: location, imageData: image.pngData()!, bounds: boundsSring, paraStyle: paraStyle.rawValue,contentMode: contentMode.rawValue)
        return model
    }
    
}
