//
//  LWPopManger.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/27.
//

import Foundation
import UIKit
import PopMenu
import JXPhotoBrowser

class LWPopManager: NSObject {
    static func PresentPopMenu(sourceView view:ScalableImageView){
        let popManager = PopMenuManager.default
        popManager.actions = [
            PopMenuDefaultAction(title: "查看图片",didSelect: { action in
                let img = view.viewModel.image
                let imgFrame = view.delegate?
                //图片浏览器数据源
                let browser = JXPhotoBrowser()
                //将黑色背景替换为玻璃模糊
                for view in browser.view.subviews{
                    if view.backgroundColor == .black{
                        view.backgroundColor = .clear
                        let effect = UIBlurEffect(style: .dark)
                        let blurView = UIVisualEffectView(effect: effect)
                        view.addSubview(blurView)
                        blurView.snp.makeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                        break
                    }
                }
                
                browser.numberOfItems = { 1 }
                browser.reloadCellAtIndex = { context in
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.imageView.image = img
                }
                
                //显示图片与收回图片的转场动画
                browser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, toView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
                    //toView:大图的imageView
                    //fromView:textView里的图片附件view
                    let fromView = UIImageView(image: img)
                    fromView.contentMode = .scaleAspectFit
                    fromView.clipsToBounds = true
                    //y + 8 是为了解决奇怪的偏移量bug
                    let fromFrame = CGRect(x: attachmentFrame.origin.x, y: attachmentFrame.origin.y + 8, width: attachmentFrame.size.width, height: attachmentFrame.size.height)
                    let thumbnailFrame = self.textView.convert(fromFrame, to: toView)
                    return (fromView,thumbnailFrame)
                })
                browser.show()
            }),
            PopMenuDefaultAction(title: "图片大小",didSelect: { action in
                view.viewModel.isEditing.toggle()
                let isEditing = view.viewModel.isEditing
                if isEditing{
                    view.addEditingView()
                }else{
                    view.doneEditing()
                }
            }),
            PopMenuDefaultAction(title: "填充模式",didSelect: { action in
                view.viewModel.contentMode = .scaleAspectFill
                view.delegate?.reloadScableImage(endView: view)
            }),
            PopMenuDefaultAction(title: "适应模式",didSelect: { action in
                view.viewModel.contentMode = .scaleAspectFit
                view.delegate?.reloadScableImage(endView: view)
            }),
            PopMenuDefaultAction(title: "居中",didSelect: { action in
                view.viewModel.paraStyle = centerParagraphStyle
                view.delegate?.reloadScableImage(endView: view)
            }),
            PopMenuDefaultAction(title: "居左",didSelect: { action in
                view.viewModel.paraStyle = leftParagraphStyle
                view.delegate?.reloadScableImage(endView: view)
            }),
            PopMenuDefaultAction(title: "居右",didSelect: { action in
                view.viewModel.paraStyle = rightParagraphStyle
                view.delegate?.reloadScableImage(endView: view)
            }),
        ]
        popManager.present(sourceView: self, on: nil, animated: true, completion: nil)
    }
}
