//
//  weChatViewController.swift
//  日记2.0
//
//  Created by 罗威 on 2021/11/17.
//

import UIKit
import Photos

class weChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func myCode(_ sender: Any) {
        if let myCodeImage = UIImage(named: "wechat_code.jpg"){
            saveImage(image: myCodeImage)
        }
    }
    
    @IBAction func groupCode(_ sender: Any) {
        if let groupCode = UIImage(named: "wechat_group_code.jpg"){
            saveImage(image: groupCode)
        }
    }
    
    private func saveImage(image: UIImage) {
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
        self.present(ac, animated: true, completion: nil)
    }
    
}
