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
            LWImageSaver.shared.saveImage(image: myCodeImage)
        }
    }
    
    @IBAction func groupCode(_ sender: Any) {
        if let groupCode = UIImage(named: "wechat_group_code.jpg"){
            LWImageSaver.shared.saveImage(image: groupCode)
        }
    }
    
    
    
}
