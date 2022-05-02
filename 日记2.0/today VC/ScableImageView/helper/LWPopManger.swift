//
//  LWPopManger.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/27.
//

import Foundation
import UIKit
import PopMenu

class LWPopManager: NSObject {
    let popManager = PopMenuManager.default
    
    func PresentPopMenu(scImage view:ScalableImageView, sourceView:UIButton){
        popManager.popMenuShouldDismissOnSelection = false
        popManager.actions = [
            PopMenuDefaultAction(title: "调整图片大小",image: UIImage(systemName: "square.dashed"), didSelect: { action in
                let isEditing = view.viewModel.isEditing
                if !isEditing{
                    view.viewModel.isEditing = true
                    view.addDotView()
                }
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "图片填充相框",image: UIImage(systemName: "aspectratio"),didSelect: { action in
                view.viewModel.contentMode = .scaleAspectFill
                view.delegate?.reloadScableImage(endView: view,shouldAddDoneView: true)
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "图片适应相框",image: UIImage(systemName: "aspectratio"),didSelect: { action in
                view.viewModel.contentMode = .scaleAspectFit
                view.delegate?.reloadScableImage(endView: view,shouldAddDoneView: true)
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "居中",image: UIImage(systemName: "text.aligncenter"),didSelect: { action in
                view.viewModel.paraStyle = imageCenterParagraphStyle
                view.delegate?.reloadScableImage(endView: view,shouldAddDoneView: true)
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "居左",image: UIImage(systemName: "text.alignleft"),didSelect: { action in
                
                view.viewModel.paraStyle = imageLeftParagraphStyle
                view.delegate?.reloadScableImage(endView: view,shouldAddDoneView: true)
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "居右",image: UIImage(systemName: "text.alignright"),didSelect: { action in

                view.viewModel.paraStyle = imageRightParagraphStyle
                view.delegate?.reloadScableImage(endView: view,shouldAddDoneView: true)
                self.dismissPopMenu()
            }),
            PopMenuDefaultAction(title: "保存",image: UIImage(systemName: "square.and.arrow.down"),didSelect: { action in
                LWImageSaver.shared.saveImage(image: view.viewModel.image)
            }),
            PopMenuDefaultAction(title: "删除",image: UIImage(systemName: "trash"),color: .red, didSelect: { action in
                view.viewModel.getNewestLocation(attributedString: view.delegate!.attributedText) {
                    let deleteRange = NSRange(location: view.viewModel.location, length: 1)
                    view.delegate?.textStorage.replaceCharacters(in: deleteRange, with: " ")
                    view.delegate?.textStorage.addAttribute(.paragraphStyle, value: imageLeftParagraphStyle, range: deleteRange)
                    
                }
                self.dismissPopMenu()
            }),
        ]
        popManager.present(sourceView: sourceView, on: nil, animated: true, completion: nil)
    }
    
    ///手动dismiss popMenu
    func dismissPopMenu(){
        if let topVC = UIApplication.getTopViewController() as? PopMenuViewController{
            topVC.dismiss(animated: true, completion: nil)
        }
    }
}
