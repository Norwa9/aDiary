//
//  LWImageSaver.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/2.
//

import Foundation
import Photos
import UIKit

class LWImageSaver{
    static let shared = LWImageSaver()
    
    public func saveImage(image:UIImage?){
        guard let image = image else {
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { [weak self](isSuccess, error) in
            
            DispatchQueue.main.async {
                
                if isSuccess {// 成功
                    self?.presentSucessAC()
                }
            }
        })
    }
    
    private func presentSucessAC(){
        let ac = UIAlertController(title: "保存成功", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (_) in
        }))
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
}
