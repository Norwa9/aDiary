//
//  LWPhotoPrivacyHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/5/3.
//

import Foundation
import Photos
import UIKit

class LWPhotoPrivacyHelper{
    static let shared = LWPhotoPrivacyHelper()
    
    func checkPhotoAccessabality(_ completion: @escaping () -> ()){
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized,.limited:
                    completion()
                default: // denied, notDetermined, restricted(家长控制)
                    // 无权限，请求打开权限
                    self.showPhotoPrivacyTips()
                }
            }
        }
    }
    
    func showPhotoPrivacyTips(){
        let ac = UIAlertController(title: "无相册权限", message: "请在设置中开启", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
            (action) -> Void in
            let url = URL(string: UIApplication.openSettingsURLString)
            if let url = url, UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: {
                                                (success) in
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        ac.addAction(cancelAction)
        ac.addAction(settingsAction)
        UIApplication.getTopViewController()?.present(ac, animated: true, completion: nil)
    }
}
