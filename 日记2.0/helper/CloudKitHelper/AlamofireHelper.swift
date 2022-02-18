//
//  AlamofireHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/18.
//

import Foundation
import Alamofire

//Alamofire监控网络，只能调用一次监听一次
func hasNetwork(completionHandler: @escaping (Bool) -> Void){
    var manager: NetworkReachabilityManager?
    manager = NetworkReachabilityManager(host: "www.apple.com")
    manager?.startListening { status in
        print("网络状态: \(status)")
        if status == .reachable(.ethernetOrWiFi) { //WIFI
            print("wifi")
            completionHandler(true)
        } else if status == .reachable(.cellular) { // 蜂窝网络
            print("4G")
            completionHandler(true)
        } else if status == .notReachable { // 无网络
            completionHandler(false)
        } else { // 其他
            completionHandler(true)
        }
    }
}
